import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../domain/entities/journalist_article.dart';

/// One article in a feed, as any reader sees it.
///
/// Unlike [JournalistArticleTile] — the author's own row, which carries edit,
/// publish and delete — this one offers nothing but the article. Keeping them
/// apart means neither has to ask who is looking at it.
class PublishedArticleTile extends StatelessWidget {
  final JournalistArticleEntity article;
  final VoidCallback onTap;

  const PublishedArticleTile({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Cover(url: article.thumbnailUrl),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppLocalizations.of(context).byAuthor(article.author),
                      style: theme.textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (article.description.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        article.description,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _Footer(article: article),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final JournalistArticleEntity article;

  const _Footer({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final publishedAt = article.publishedAt;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            publishedAt == null ? '' : DateFormat('MMM d').format(publishedAt),
            style: theme.textTheme.labelSmall,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 14,
              color: theme.textTheme.labelSmall?.color,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              AppLocalizations.of(context)
                  .viewsCount(_compactCount(article.viewCount)),
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }

  /// 14200 reads as "14.2K": a reader cares about the order of magnitude, not
  /// the exact number.
  static String _compactCount(int value) {
    if (value < 1000) {
      return '$value';
    }

    final thousands = value / 1000;

    return '${thousands.toStringAsFixed(thousands < 10 ? 1 : 0)}K';
  }
}

class _Cover extends StatelessWidget {
  final String url;

  const _Cover({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.card),
      ),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: url.isEmpty
            ? _placeholder(context)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => _placeholder(context),
                errorWidget: (_, __, ___) => _placeholder(context),
              ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Theme.of(context).textTheme.labelSmall?.color,
        ),
      ),
    );
  }
}
