import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_shadows.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: AppDimensions.buttonHeight,
        padding:
            const EdgeInsets.symmetric(horizontal: AppDimensions.spacing24),
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: colors.borderSubtle),
          boxShadow: AppShadows.elevated,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: AppDimensions.iconDefault, color: colors.textPrimary),
            const SizedBox(width: AppDimensions.spacing10),
            Text(
              label,
              style:
                  AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
