import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';

class RelatedArticleCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const RelatedArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: article.coverHorizontalUrl,
              width: AppSpacing.relatedCardImageWidth,
              height: AppSpacing.relatedCardImageHeight,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                width: AppSpacing.relatedCardImageWidth,
                height: AppSpacing.relatedCardImageHeight,
                color: AppColors.border,
              ),
              errorWidget: (_, _, _) => Container(
                width: AppSpacing.relatedCardImageWidth,
                height: AppSpacing.relatedCardImageHeight,
                color: AppColors.border,
                child: const Icon(Icons.broken_image_outlined,
                    color: AppColors.textSecondary),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  article.title,
                  style: AppTypography.label.copyWith(color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
