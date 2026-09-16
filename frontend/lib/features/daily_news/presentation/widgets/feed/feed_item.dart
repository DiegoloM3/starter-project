import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/search/highlighted_text.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/relative_time_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/category_label.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/you_badge.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/article_thumbnail.dart';

/// One row of a list of stories: an optional red row number, the kicker, the
/// headline, the teaser when there is one, and the dateline in small
/// capitals. The thumb slot appears only when there is an image (or always,
/// on the left, in lists that want a stable scan column).
class FeedItem extends StatelessWidget {
  final ArticleEntity article;
  final bool isOwn;
  final VoidCallback onTap;

  /// Position in the list, printed as "02" in red before the kicker.
  final int? number;

  /// Saved list puts the thumb on the left as a stable scan column and
  /// always shows a tile (fallback when there is no image).
  final bool thumbnailLeft;
  final String? metaOverride;

  /// Search query whose matches are marked in the title and teaser.
  final String highlight;

  const FeedItem({
    super.key,
    required this.article,
    required this.onTap,
    this.isOwn = false,
    this.number,
    this.thumbnailLeft = false,
    this.metaOverride,
    this.highlight = '',
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final showThumb = thumbnailLeft || article.hasImage;
    final thumb = showThumb
        ? ArticleThumbnail(article: article, size: thumbnailLeft ? AppSizes.savedThumb : AppSizes.thumb)
        : null;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (number != null)
              Text('$number'.padLeft(2, '0'), style: AppTypography.numeral(11).copyWith(color: palette.primary)),
            CategoryLabel(category: article.category, color: palette.inkSecondary),
            if (isOwn) const YouBadge(),
          ],
        ),
        const SizedBox(height: 7),
        HighlightedText(text: article.title, query: highlight, style: AppTypography.cardTitle.copyWith(color: palette.ink)),
        if (article.description case final teaser?) ...[
          const SizedBox(height: AppSpacing.xs),
          HighlightedText(
            text: teaser,
            query: highlight,
            maxLines: 2,
            style: AppTypography.bodySmall.copyWith(color: palette.inkBody),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          (metaOverride ?? '${article.author} · ${RelativeTimeFormatter.ago(article.publishedAt)}').toUpperCase(),
          style: AppTypography.caption.copyWith(color: palette.inkSecondary),
        ),
      ],
    );

    return InkWell(
      onTap: onTap,
      hoverColor: palette.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.rowHorizontal,
          vertical: AppSpacing.rowVertical,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thumb != null && thumbnailLeft) ...[thumb, const SizedBox(width: 14)],
            Expanded(child: text),
            if (thumb != null && !thumbnailLeft) ...[const SizedBox(width: 14), thumb],
          ],
        ),
      ),
    );
  }
}
