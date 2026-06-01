import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/shared/widgets/tortutip_chip.dart';
import 'package:tortutip/shared/widgets/tortutip_skeleton.dart';

class TortuArticleListCard extends StatelessWidget {
  final ArticleEntity article;
  final CategoryEntity? category;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;
  final String? authorName;
  final String? authorAvatarUrl;

  const TortuArticleListCard({
    super.key,
    required this.article,
    this.category,
    required this.isSaved,
    required this.onTap,
    required this.onBookmarkTap,
    this.authorName,
    this.authorAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusLg),
                    topRight: Radius.circular(AppSpacing.radiusLg),
                  ),
                child: CachedNetworkImage(
                  imageUrl: article.coverHorizontalUrl,
                  height: AppSpacing.articleListCardImageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => TortuSkeletonImage(
                    height: AppSpacing.articleListCardImageHeight,
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: AppSpacing.articleListCardImageHeight,
                    width: double.infinity,
                    color: AppColors.surface,
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: GestureDetector(
                  onTap: onBookmarkTap,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.white.withValues(alpha: 0.9),
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (category != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs, bottom: AppSpacing.xs),
                        child: TortuCategoryChip.fromName(category!.name),
                      ),
                    ],
                    Text(
                      '${article.readTimeMinutes} min read',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  article.title,
                  style: AppTypography.h2.copyWith(
                    color: isSaved
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _extractDescription(article.body),
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (authorName != null || authorAvatarUrl != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: (authorAvatarUrl != null && authorAvatarUrl!.isNotEmpty)
                            ? NetworkImage(authorAvatarUrl!)
                            : null,
                        child: (authorAvatarUrl == null || authorAvatarUrl!.isEmpty)
                            ? Text(
                                (authorName != null && authorName!.isNotEmpty)
                                    ? authorName![0].toUpperCase()
                                    : '?',
                                style: AppTypography.caption,
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        (authorName != null && authorName!.isNotEmpty) ? authorName! : 'Unknown author',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  static String _extractDescription(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map && decoded['ops'] is List) {
        final ops = decoded['ops'] as List;
        final buffer = StringBuffer();
        for (final op in ops) {
          if (op is Map && op['insert'] is String) {
            buffer.write(op['insert'] as String);
          }
        }
        final text = buffer.toString();
        return text.substring(0, min(120, text.length));
      }
    } catch (_) {
      // Fall through to raw body
    }
    return rawBody.substring(0, min(120, rawBody.length));
  }
}
