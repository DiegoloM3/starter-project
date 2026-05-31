import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/article_source.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_bloc.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_event.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/remote_article_state.dart';

import '../../../../../core/design_system/design_system.dart';

class DailyNews extends HookWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();

    useEffect(() {
      void listener() {
        if (scrollController.hasClients &&
            scrollController.position.pixels >
                scrollController.position.maxScrollExtent * 0.8) {
          context.read<RemoteArticlesBloc>().add(const LoadMoreArticles());
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: const Center(child: CupertinoActivityIndicator()),
          );
        }
        if (state is RemoteArticlesError) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: ErrorDisplay(
              message: state.failure!.message,
              onRetry: () =>
                  context.read<RemoteArticlesBloc>().add(const GetArticles()),
              icon: Icons.wifi_off_outlined,
            ),
          );
        }
        if (state is RemoteArticlesDone) {
          return _buildArticlesPage(context, state, scrollController);
        }
        return const SizedBox.shrink();
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => context.goToProfile(),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: context.colorScheme.surfaceContainer,
            child: Icon(
              Icons.person_outline,
              color: context.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'SYMMETRY ',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            TextSpan(
              text: 'NEWS',
              style: context.textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.goToSearch(),
          icon: Icon(Icons.search, color: context.colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildArticlesPage(
    BuildContext context,
    RemoteArticlesDone state,
    ScrollController scrollController,
  ) {
    final articles = state.articles ?? [];
    final isLoadingMore = state.isLoadingMore;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: articles.isEmpty
          ? Center(child: Text(context.l10n.newsNoArticlesFound))
          : ListView.builder(
              controller: scrollController,
              itemCount: articles.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == articles.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CupertinoActivityIndicator()),
                  );
                }

                final article = articles[index];

                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BreakingBanner(
                        headlines: articles
                            .take(3)
                            .map(
                              (article) =>
                                  article.title ?? article.description ?? '',
                            )
                            .toList(),
                      ),
                      HeroArticleCard(
                        title: article.title ?? '',
                        imageUrl: article.urlToImage,
                        description: article.description,
                        author: article.author,
                        publishedAt: _formatTime(article.publishedAt),
                        onTap: () => _onArticlePressed(context, article),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          children: [
                            Text(
                              'TOP HEADLINES',
                              style: context.textTheme.labelLarge?.copyWith(
                                letterSpacing: 0.5,
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'SEE ALL',
                                style: context.textTheme.labelLarge?.copyWith(
                                  letterSpacing: 0.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                  );
                }

                return _HeadlineTile(
                  article: article,
                  onTap: () => _onArticlePressed(context, article),
                );
              },
            ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    context.goToArticleDetail(
      Uri.encodeComponent(article.url!),
      article: article,
    );
  }

  String _formatTime(String? t) {
    if (t == null) return '';
    try {
      final diff = DateTime.now().difference(DateTime.parse(t));
      if (diff.inHours < 1) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hrs ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return t;
    }
  }
}

class _HeadlineTile extends StatelessWidget {
  const _HeadlineTile({required this.article, this.onTap});

  final ArticleEntity article;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _category(article),
                    style: context.textTheme.labelSmall?.copyWith(
                      letterSpacing: 0.6,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(article.publishedAt),
                    style: context.textTheme.labelLarge?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (article.urlToImage != null &&
                article.urlToImage!.isNotEmpty) ...[
              const SizedBox(width: 12),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      width: 90,
                      height: 72,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 90,
                        height: 72,
                        color: AppColors.surfaceContainer,
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 90,
                        height: 72,
                        color: AppColors.surfaceContainer,
                        child: const Icon(
                          Icons.image,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: BlocSelector<BookmarkBloc, BookmarkState, bool>(
                      selector: (state) {
                        final sourceId = article.url ?? '';
                        return state is BookmarksDone &&
                            sourceId.isNotEmpty &&
                            state.bookmarks.any(
                              (bookmark) =>
                                  bookmark.sourceId == sourceId &&
                                  bookmark.source == ArticleSource.api,
                            );
                      },
                      builder: (context, isBookmarked) {
                        return GestureDetector(
                          onTap: () => _onBookmarkPressed(
                            context,
                            article,
                            isBookmarked,
                          ),
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 18,
                            color: context.colorScheme.onPrimary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onBookmarkPressed(
    BuildContext context,
    ArticleEntity article,
    bool isBookmarked,
  ) {
    final sourceId = article.url ?? '';
    if (sourceId.isEmpty) {
      return;
    }

    if (isBookmarked) {
      context.read<BookmarkBloc>().add(
        RemoveBookmarkEvent(sourceId, ArticleSource.api),
      );
      context.showSnackBar('Article removed.');
      return;
    }

    context.read<BookmarkBloc>().add(
      AddBookmarkEvent(
        BookmarkEntity(
          sourceId: sourceId,
          source: ArticleSource.api,
          title: article.title,
          description: article.description,
          imageUrl: article.urlToImage,
          url: article.url,
          author: article.author,
          publishedAt: article.publishedAt,
          content: article.content,
        ),
      ),
    );
    context.showSnackBar('Article saved.');
  }

  String _category(ArticleEntity article) {
    return 'NEWS';
  }

  String _formatTime(String? t) {
    if (t == null) return '';
    try {
      final diff = DateTime.now().difference(DateTime.parse(t));
      if (diff.inHours < 1) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hrs ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return t;
    }
  }
}
