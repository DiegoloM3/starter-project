import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_drafts.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/widgets/feed_filter_chips.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';
import 'package:news_app_clean_architecture/shared/feed/domain/entities/feed_item.dart';
import 'package:news_app_clean_architecture/shared/feed/presentation/widgets/feed_item_card.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppBar(
      title: Text(
        t.homeTitle,
        style: const TextStyle(color: Colors.black),
      ),
      actions: [
        const _AccountAction(),
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.bookmark, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildPage() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: const Center(child: CupertinoActivityIndicator()));
        }
        if (state is RemoteArticlesError) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: const Center(child: Icon(Icons.refresh)));
        }
        if (state is RemoteArticlesDone) {
          return _buildArticlesPage(context, state.articles!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: _FeedBody(newsApiArticles: articles),
      floatingActionButton: _UploadFab(),
    );
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    context.push('/saved');
  }
}

class _FeedBody extends StatefulWidget {
  final List<ArticleEntity> newsApiArticles;

  const _FeedBody({required this.newsApiArticles});

  @override
  State<_FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<_FeedBody> {
  final _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(const LoadFeedEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, feedState) {
        final visibleItems = feedState.items;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SearchAnchor(
                searchController: _searchController,
                builder: (context, controller) {
                  return SearchBar(
                    controller: controller,
                    hintText: AppLocalizations.of(context).searchHint,
                    leading: const Icon(Icons.search),
                    onChanged: (q) => context
                        .read<FeedBloc>()
                        .add(SearchQueryChangedEvent(q)),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  final q = controller.text.toLowerCase();
                  if (q.isEmpty) return const [];
                  return visibleItems
                      .where((i) => i.title.toLowerCase().contains(q))
                      .take(5)
                      .map((item) => ListTile(
                            title: Text(item.title),
                            onTap: () {
                              controller.closeView(item.title);
                            },
                          ))
                      .toList();
                },
              ),
            ),
            FeedFilterChips(
              filters: FeedFilter.values,
              selected: feedState.filter,
              onSelected: (f) {
                // For You is auth-gated (anon users don't have meaningful
                // saves yet). Bounce them through /login the same way the
                // bookmark FAB does.
                if (f == FeedFilter.forYou) {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is! AuthAuthenticated) {
                    context.push('/login?return=%2F');
                    return;
                  }
                }
                context.read<FeedBloc>().add(FilterChangedEvent(f));
              },
            ),
            const _LastDraftCard(),
            if (feedState.searchFallbackActive)
              Container(
                width: double.infinity,
                color: Colors.amber.shade100,
                padding: const EdgeInsets.all(8),
                child: Text(
                  AppLocalizations.of(context).semanticSearchUnavailable,
                  style:
                      TextStyle(color: Colors.amber.shade900, fontSize: 12),
                ),
              )
            else if (feedState.error != null)
              Container(
                width: double.infinity,
                color: Colors.red.shade100,
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Feed error: ${feedState.error!.localizedMessage}',
                  style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                ),
              ),
            const SizedBox(height: 4),
            Expanded(
              child: feedState.isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : feedState.filter == FeedFilter.forYou &&
                          feedState.isLoadingRecommendations
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CupertinoActivityIndicator(),
                              const SizedBox(height: 12),
                              Text(AppLocalizations.of(context)
                                  .filterForYouLoading),
                            ],
                          ),
                        )
                  : visibleItems.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              feedState.filter == FeedFilter.forYou
                                  ? AppLocalizations.of(context)
                                      .filterForYouEmpty
                                  : AppLocalizations.of(context).feedEmpty,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _onRefresh(context, feedState),
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollUpdateNotification) {
                                final position = notification.metrics.pixels;
                                final max =
                                    notification.metrics.maxScrollExtent;
                                if (max - position < 200 &&
                                    !feedState.isLoadingMore &&
                                    _hasMoreForCurrentFilter(feedState)) {
                                  context
                                      .read<FeedBloc>()
                                      .add(const LoadMoreEvent());
                                }
                              }
                              return false;
                            },
                            child: ListView.builder(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              itemCount: visibleItems.length + 1,
                              itemBuilder: (context, index) {
                                if (index == visibleItems.length) {
                                  return _PaginationFooter(
                                    isLoadingMore: feedState.isLoadingMore,
                                    hasMore:
                                        _hasMoreForCurrentFilter(feedState),
                                  );
                                }
                                final item = visibleItems[index];
                                return FeedItemCard(
                                  item: item,
                                  onTap: () => _onItemTapped(context, item),
                                );
                              },
                            ),
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onRefresh(BuildContext context, FeedState s) {
    final bloc = context.read<FeedBloc>();
    if (s.filter == FeedFilter.forYou) {
      // Re-running the filter handler is what re-fetches recommendations.
      bloc.add(const FilterChangedEvent(FeedFilter.forYou));
      return bloc.stream
          .firstWhere((next) => !next.isLoadingRecommendations);
    }
    bloc.add(const LoadFeedEvent());
    return bloc.stream.firstWhere((next) => !next.isLoading);
  }

  bool _hasMoreForCurrentFilter(FeedState s) {
    switch (s.filter) {
      case FeedFilter.news:
        return s.hasMoreNews;
      case FeedFilter.fitnessNews:
        return s.hasMoreFitness;
      case FeedFilter.community:
        return true;
      case FeedFilter.all:
        return s.hasMoreNews || s.hasMoreFitness;
      case FeedFilter.forYou:
        return false;
    }
  }

  void _onItemTapped(BuildContext context, FeedItem item) {
    switch (item) {
      case NewsApiFeedItem(:final article):
        final id = Uri.encodeComponent(article.url ?? 'unknown');
        context.push('/article/$id', extra: article);
      case JournalistFeedItem(:final article):
        context.push('/article/${article.id}');
    }
  }
}

class _PaginationFooter extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasMore;

  const _PaginationFooter({
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No more articles',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      );
    }
    return const SizedBox(height: 16);
  }
}

class _LastDraftCard extends StatefulWidget {
  const _LastDraftCard();

  @override
  State<_LastDraftCard> createState() => _LastDraftCardState();
}

class _LastDraftCardState extends State<_LastDraftCard> {
  late final Stream<List<DraftArticleEntity>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = sl<WatchDraftsUseCase>().call(params: null);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DraftArticleEntity>>(
      stream: _stream,
      builder: (context, snapshot) {
        final drafts = snapshot.data;
        if (drafts == null || drafts.isEmpty) {
          return const SizedBox.shrink();
        }
        final draft = drafts.first;
        final title = draft.title.isEmpty ? 'Untitled draft' : draft.title;
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Card(
            color: theme.colorScheme.primaryContainer,
            child: InkWell(
              onTap: () =>
                  context.push('/article/upload?draftId=${draft.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_note_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Continue your draft',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UploadFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return FloatingActionButton(
          onPressed: () {
            if (state is AuthAuthenticated) {
              context.push('/article/upload');
            } else {
              context.push('/login');
            }
          },
          child: const Icon(Icons.add),
        );
      },
    );
  }
}

class _AccountAction extends StatelessWidget {
  const _AccountAction();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return _AuthenticatedMenu(state: state);
        }
        return GestureDetector(
          onTap: () => context.push('/login'),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.person_outline, color: Colors.black),
          ),
        );
      },
    );
  }
}

class _AuthenticatedMenu extends StatelessWidget {
  final AuthAuthenticated state;
  const _AuthenticatedMenu({required this.state});

  @override
  Widget build(BuildContext context) {
    final label = state.user.displayName ?? state.user.email ?? 'Account';
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle, color: Colors.black),
      onSelected: (value) {
        switch (value) {
          case 'my-articles':
            context.push('/my-articles');
          case 'signout':
            context.read<AuthBloc>().add(SignOutEvent());
        }
      },
      itemBuilder: (context) {
        final t = AppLocalizations.of(context);
        return [
          PopupMenuItem<String>(
            enabled: false,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'my-articles',
            child: Text(t.menuMyArticles),
          ),
          PopupMenuItem<String>(
            value: 'signout',
            child: Text(t.menuSignOut),
          ),
        ];
      },
    );
  }
}
