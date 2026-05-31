import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/core/design_system/design_system.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/routes/article_routes.dart';
import 'package:news_app_clean_architecture/features/community_articles/routes/community_routes.dart';

import '../../domain/entities/article_source.dart';
import '../../domain/entities/bookmark_entity.dart';
import '../bloc/bookmark_bloc.dart';
import '../bloc/bookmark_event.dart';
import '../bloc/bookmark_state.dart';

class SavedArticlesScreen extends HookWidget {
  const SavedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocBuilder<BookmarkBloc, BookmarkState>(
        builder: (context, state) {
          if (state is BookmarksLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (state is BookmarksDone) {
            return _buildBody(context, state.bookmarks);
          }
          return const SizedBox();
        },
      ),
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
      title: Text(
        'Symmetry NEWS',
        style: context.textTheme.titleLarge?.copyWith(
          color: context.colorScheme.onSurface,
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

  Widget _buildBody(BuildContext context, List<BookmarkEntity> bookmarks) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Saved',
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '${bookmarks.length} ARTICLE${bookmarks.length == 1 ? '' : 'S'}',
                  style: context.textTheme.labelLarge?.copyWith(
                    letterSpacing: 0.6,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: Divider(height: 1)),
        if (bookmarks.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.bookmark_border,
                      size: 48,
                      color: AppColors.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No saved articles yet.\nTap the bookmark icon on any article to save it.',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          // First bookmark: hero card
          SliverToBoxAdapter(
            child: Stack(
              children: [
                HeroArticleCard(
                  title: bookmarks[0].title ?? '',
                  imageUrl: bookmarks[0].imageUrl,
                  category: bookmarks[0].source == ArticleSource.community
                      ? 'COMMUNITY'
                      : 'NEWS',
                  description: bookmarks[0].description,
                  onTap: () => _onBookmarkPressed(context, bookmarks[0]),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _onRemoveBookmark(context, bookmarks[0]),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Remaining bookmarks: compact rows
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final bookmark = bookmarks[index + 1];
              return _CompactBookmarkTile(
                bookmark: bookmark,
                onTap: () => _onBookmarkPressed(context, bookmark),
                onRemove: () => _onRemoveBookmark(context, bookmark),
              );
            }, childCount: bookmarks.length - 1),
          ),
        ],
        // ARCHIVED COLLECTIONS section
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'ARCHIVED COLLECTIONS',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  color: AppColors.surfaceContainerLow,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.bookmark_border,
                        size: 36,
                        color: AppColors.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No saved articles yet. Tap the bookmark icon on any article to save it.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  void _onBookmarkPressed(BuildContext context, BookmarkEntity bookmark) {
    if (bookmark.source == ArticleSource.community) {
      context.goToCommunityDetailById(bookmark.sourceId);
      return;
    }

    final article = ArticleEntity(
      title: bookmark.title,
      description: bookmark.description,
      content: bookmark.content,
      author: bookmark.author,
      urlToImage: bookmark.imageUrl,
      url: bookmark.sourceId,
      publishedAt: bookmark.publishedAt,
    );

    context.goToArticleDetail(
      Uri.encodeComponent(bookmark.sourceId),
      article: article,
    );
  }

  void _onRemoveBookmark(BuildContext context, BookmarkEntity bookmark) {
    context.read<BookmarkBloc>().add(
      RemoveBookmarkEvent(bookmark.sourceId, bookmark.source),
    );
  }
}

class _CompactBookmarkTile extends StatelessWidget {
  const _CompactBookmarkTile({
    required this.bookmark,
    required this.onTap,
    required this.onRemove,
  });

  final BookmarkEntity bookmark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

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
                  Row(
                    children: [
                      CategoryBadge(
                        bookmark.source == ArticleSource.community
                            ? 'COMMUNITY'
                            : 'NEWS',
                        filled: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    bookmark.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.bookmark,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
