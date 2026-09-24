import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../domain/entities/article.dart';
import 'article_timestamp.dart';

/// The lead story: one article given the whole width, a large cover and the
/// full headline treatment.
///
/// Only the first article of the feed gets this. A list where everything
/// shouts equally has no hierarchy, and hierarchy is what makes a news feed
/// scannable.
class LeadArticleCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const LeadArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _CardSurface(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ArticleImage(
            url: article.urlToImage,
            height: 200,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.card),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasSource) ...[
                  Text(
                    article.author!,
                    style: theme.textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Text(
                  article.title ?? '',
                  style: theme.textTheme.headlineMedium,
                ),
                if (_hasDescription) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    article.description!,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: ArticleTimestamp(
                        rawDate: article.publishedAt,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context).readMore,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasSource => article.author != null && article.author!.isNotEmpty;

  bool get _hasDescription =>
      article.description != null && article.description!.isNotEmpty;
}

/// Every article after the lead: a thumbnail, the headline, and when it
/// happened. Enough to decide whether to open it, and nothing else.
class CompactArticleCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  /// An action for this row, such as removing it from the saved list. Rows
  /// that only lead somewhere leave it out.
  final Widget? trailing;

  const CompactArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _CardSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ArticleImage(
              url: article.urlToImage,
              height: 84,
              width: 84,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.author != null && article.author!.isNotEmpty) ...[
                    Text(
                      article.author!,
                      style: theme.textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  Text(
                    article.title ?? '',
                    style: theme.textTheme.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ArticleTimestamp(
                    rawDate: article.publishedAt,
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _CardSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _CardSurface({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardRadius,
          child: child,
        ),
      ),
    );
  }
}

/// A cover image that degrades gracefully: news feeds are full of articles
/// with a missing or broken image, and a torn icon on a grey box looks like a
/// bug rather than a design.
class _ArticleImage extends StatelessWidget {
  final String? url;
  final double height;
  final double? width;
  final BorderRadius borderRadius;

  const _ArticleImage({
    required this.url,
    required this.height,
    required this.borderRadius,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: url == null || url!.isEmpty
            ? _placeholder(context)
            : CachedNetworkImage(
                imageUrl: url!,
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
          Icons.newspaper_outlined,
          color: Theme.of(context).textTheme.labelSmall?.color,
        ),
      ),
    );
  }
}
