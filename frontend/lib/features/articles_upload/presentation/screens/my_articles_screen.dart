import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/repository/auth_service.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/articles_list/articles_list_bloc.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/articles_list/articles_list_event.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/articles_list/articles_list_state.dart';
import 'package:news_app_clean_architecture/shared/widgets/article_skeleton.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/widgets/article_upload_tile.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

class MyArticlesScreen extends StatelessWidget {
  const MyArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ArticlesListBloc>(
      create: (_) => sl<ArticlesListBloc>()..add(const FetchArticles()),
      child: const _MyArticlesView(),
    );
  }
}

class _MyArticlesView extends StatefulWidget {
  const _MyArticlesView();

  @override
  State<_MyArticlesView> createState() => _MyArticlesViewState();
}

class _MyArticlesViewState extends State<_MyArticlesView> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    if (_scrollCtrl.offset >= max * 0.8) {
      context.read<ArticlesListBloc>().add(const LoadMoreArticles());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = sl<AuthService>();
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myArticles),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Row(
              children: [
                if (auth.isGoogleUser)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (auth.photoURL != null)
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(auth.photoURL!),
                          ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            auth.displayName ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/Login', (r) => false);
                    }
                  },
                  icon: Icon(Icons.logout, size: 18, color: colors.error),
                  label: Text(l10n.signOut,
                      style: TextStyle(fontSize: 13, color: colors.error)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<ArticlesListBloc, ArticlesListState>(
        builder: (context, state) {
          if (state is ArticlesListLoading || state is ArticlesListInitial) {
            return const ArticleSkeletonList();
          }
          if (state is ArticlesListError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ArticlesListBloc>().add(const FetchArticles()),
            );
          }
          if (state is ArticlesListLoaded) {
            if (state.allArticles.isEmpty) {
              return const _EmptyView();
            }
            final visible = state.visibleArticles;
            return Column(
              children: [
                _PremiumSearchBar(
                  controller: _searchCtrl,
                  onChanged: (q) => context
                      .read<ArticlesListBloc>()
                      .add(SearchQueryChanged(q)),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '${visible.length} ${visible.length == 1 ? 'article' : 'articles'}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<ArticlesListBloc>()
                          .add(const FetchArticles());
                    },
                    child: visible.isEmpty
                        ? _NoMatchView(query: state.query)
                        : ListView.builder(
                            controller: _scrollCtrl,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: visible.length + (state.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= visible.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              return _buildArticleCard(
                                  context, visible[index], index);
                            },
                          ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: FilledButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(context, '/CreateArticle');
              if (context.mounted) {
                context.read<ArticlesListBloc>().add(const FetchArticles());
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: Text(
              l10n.publish,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(
      BuildContext context, ArticleUploadEntity article, int index) {
    return ArticleUploadTile(
      article: article,
      onTap: () => Navigator.pushNamed(
        context,
        '/ArticleUploadDetail',
        arguments: article,
      ),
      onDelete: () => _confirmDelete(context, article.id!),
    );
  }

  void _confirmDelete(BuildContext context, String articleId) {
    final bloc = context.read<ArticlesListBloc>();
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteArticle),
        content: Text(l10n.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              bloc.add(DeleteArticleRequested(articleId));
              Navigator.pop(dialogCtx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _PremiumSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _PremiumSearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: l10n.clearSearch,
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          filled: true,
          fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          isDense: true,
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final faint = colors.onSurface.withValues(alpha: 0.3);
    final muted = colors.onSurface.withValues(alpha: 0.6);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Icon(Icons.article_outlined, size: 80, color: faint),
        const SizedBox(height: 20),
        Center(
          child: Text(l10n.noArticlesYet,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600, color: muted)),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(l10n.tapPublishHint,
              style: TextStyle(fontSize: 14, color: muted)),
        ),
      ],
    );
  }
}

class _NoMatchView extends StatelessWidget {
  final String query;
  const _NoMatchView({required this.query});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.search_off, size: 56, color: muted),
        const SizedBox(height: 12),
        Center(
          child: Text(l10n.noMatchFor(query),
              style: TextStyle(fontSize: 16, color: muted),
              textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: colors.error.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
