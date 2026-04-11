import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_shadows.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';

class CardCompact extends StatelessWidget {
  final String title;
  final String date;
  final String? imageUrl;
  final IconData actionIcon;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;

  const CardCompact({
    super.key,
    required this.title,
    required this.date,
    this.imageUrl,
    this.actionIcon = Icons.bookmark_outline,
    this.onTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing12),
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: AppShadows.cardSubtle,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: Container(
                width: AppDimensions.cardImageCompact,
                height: AppDimensions.cardImageCompact,
                color: colors.bgInput,
                child: imageUrl != null
                    ? Image.network(imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.image_outlined,
                            color: colors.textPlaceholder))
                    : Icon(Icons.image_outlined, color: colors.textPlaceholder),
              ),
            ),
            const SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.compactTitle
                        .copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppDimensions.spacing4),
                  Text(
                    date,
                    style: AppTypography.footnote
                        .copyWith(color: colors.textPlaceholder),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacing8),
            GestureDetector(
              onTap: onActionTap,
              child: Icon(actionIcon,
                  size: AppDimensions.iconMd, color: colors.textPlaceholder),
            ),
          ],
        ),
      ),
    );
  }
}
