import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/app_image.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

import '../../domain/entities/article.dart';
import 'article_actions.dart';
import 'news_formatting.dart';

/// "SOURCE · 15 min ago" above a story's headline.
class _StoryKicker extends StatelessWidget {
  final ArticleEntity article;

  const _StoryKicker({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final source = article.sourceName ?? '';
    final ago = timeAgo(article.publishedAt, context.l10n);
    return Text.rich(
      TextSpan(
        children: [
          if (source.isNotEmpty)
            TextSpan(
              text: source.toUpperCase(),
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          if (source.isNotEmpty && ago.isNotEmpty)
            const TextSpan(text: '  ·  '),
          TextSpan(text: ago),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelMedium,
    );
  }
}

/// The day's first story: headline and summary at full size, no photo --
/// the carousel above already carries the pictures.
class LeadStory extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const LeadStory({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StoryKicker(article: article),
                  const SizedBox(height: 8),
                  Text(article.title ?? '',
                      style: theme.textTheme.headlineLarge),
                  if ((article.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(article.description!,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    article.author ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                ShareButton(article: article),
                BookmarkButton(article: article),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A regular story: kicker, headline and byline, photo on the right. No
/// fixed height, so long headlines and large system fonts never get cut.
class StoryRow extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  /// See [AppImage.isOffline].
  final bool isOffline;

  const StoryRow({
    super.key,
    required this.article,
    required this.onTap,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StoryKicker(article: article),
                  const SizedBox(height: 6),
                  Text(
                    article.title ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.author ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Bookmark on the photo's corner, same as the featured cards.
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AppImage(
                        url: article.urlToImage, isOffline: isOffline),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: BookmarkButton(article: article, onPhoto: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small uppercase heading with an accent bar, splitting the feed.
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}
