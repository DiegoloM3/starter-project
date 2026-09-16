import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/article_thumbnail.dart';

/// Row of My Articles: row number and status in small capitals, title, date,
/// 64dp tile and the visible Edit / Delete blocks (never hidden behind a swipe).
class MyArticleRow extends StatelessWidget {
  final ArticleEntity article;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int? number;

  const MyArticleRow({
    super.key,
    required this.article,
    required this.now,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.number,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      hoverColor: palette.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.rowHorizontal, vertical: AppSpacing.rowVertical),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (number != null)
                            Text('$number'.padLeft(2, '0'), style: AppTypography.numeral(11).copyWith(color: palette.primary)),
                          const _StatusBadge(),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(article.title, style: AppTypography.cardTitle.copyWith(color: palette.ink)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        DateFormat('d MMM yyyy · H:mm').format(article.publishedAt.toLocal()).toUpperCase(),
                        style: AppTypography.caption.copyWith(color: palette.inkSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                ArticleThumbnail(article: article, size: AppSizes.smallThumb),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _ActionBlock(label: 'Edit', icon: Icons.edit_outlined, color: palette.ink, onPressed: onEdit),
                const SizedBox(width: AppSpacing.sm),
                _ActionBlock(label: 'Delete', icon: Icons.delete_outline_rounded, color: palette.primaryDeep, onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: palette.successContainer,
      child: Text(
        'PUBLISHED',
        style: AppTypography.overline.copyWith(fontSize: 9.5, color: palette.onSuccessContainer),
      ),
    );
  }
}

class _ActionBlock extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionBlock({required this.label, required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: AppRules.strong),
        minimumSize: const Size(0, AppSizes.inCardButton),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        textStyle: AppTypography.buttonSecondary,
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
