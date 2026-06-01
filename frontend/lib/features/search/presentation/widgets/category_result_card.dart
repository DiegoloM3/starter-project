import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';

class CategoryResultCard extends StatelessWidget {
  final CategoryEntity category;
  final int articleCount;
  final VoidCallback onTap;

  const CategoryResultCard({
    super.key,
    required this.category,
    required this.articleCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: CachedNetworkImage(
                imageUrl: category.iconUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorWidget: (ctx, url, err) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surface,
                  child: const Icon(Icons.category,
                      color: AppColors.textTertiary),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: AppTypography.bodyLg
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$articleCount articles',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
