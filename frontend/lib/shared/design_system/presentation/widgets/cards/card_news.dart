import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_shadows.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';

class CardNews extends StatelessWidget {
  final String title;
  final String? description;
  final String date;
  final String? imageUrl;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final Widget? trailing;
  final Widget? sectionBadge;

  const CardNews({
    super.key,
    required this.title,
    this.description,
    required this.date,
    this.imageUrl,
    this.isBookmarked = false,
    this.onTap,
    this.onBookmarkTap,
    this.trailing,
    this.sectionBadge,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacing12,
          AppDimensions.spacing12,
          AppDimensions.spacing10,
          AppDimensions.spacing12,
        ),
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: AppShadows.cardStandard,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Container(
                width: AppDimensions.cardImageStandard,
                height: AppDimensions.cardImageStandard,
                color: colors.bgInput,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_outlined,
                          color: colors.textPlaceholder,
                        ),
                      )
                    : Icon(Icons.image_outlined, color: colors.textPlaceholder),
              ),
            ),
            const SizedBox(width: AppDimensions.spacing14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (sectionBadge != null) ...[
                    sectionBadge!,
                    const SizedBox(height: AppDimensions.spacing6),
                  ],
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.cardTitle
                        .copyWith(color: colors.textPrimary),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subtitle
                          .copyWith(color: colors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.spacing6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: AppDimensions.iconXs,
                          color: colors.textPlaceholder),
                      const SizedBox(width: AppDimensions.spacing6),
                      Text(
                        date,
                        style: AppTypography.badge.copyWith(
                          color: colors.textPlaceholder,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacing8),
            if (trailing != null)
              trailing!
            else
              GestureDetector(
                onTap: onBookmarkTap,
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  size: AppDimensions.iconDefault,
                  color:
                      isBookmarked ? AppColors.coral : colors.textPlaceholder,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
