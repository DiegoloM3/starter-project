import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/shared/widgets/tortutip_chip.dart';
import 'package:tortutip/shared/widgets/tortutip_skeleton.dart';

class SavedArticleThumbnail extends StatelessWidget {
  final ArticleEntity article;
  final String categoryName;
  final String? fallbackImageUrl;
  final VoidCallback onTap;

  const SavedArticleThumbnail({
    super.key,
    required this.article,
    required this.categoryName,
    this.fallbackImageUrl,
    required this.onTap,
  });

  String? get _imageUrl {
    if (article.coverHorizontalUrl.isNotEmpty) return article.coverHorizontalUrl;
    if (fallbackImageUrl != null && fallbackImageUrl!.isNotEmpty) return fallbackImageUrl;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: _imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: _imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const TortuSkeletonImage(),
                      errorWidget: (context, url, error) => Container(color: AppColors.surface),
                    )
                  : Container(color: AppColors.surface),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TortuCategoryChip.fromName(categoryName),
          const SizedBox(height: AppSpacing.xs),
          Text(
            article.title,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
