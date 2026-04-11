import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_shadows.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: AppDimensions.buttonHeight,
        padding:
            const EdgeInsets.symmetric(horizontal: AppDimensions.spacing24),
        decoration: BoxDecoration(
          color: AppColors.accentGreen,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: AppShadows.ctaGreen,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppDimensions.iconDefault, color: AppColors.white),
            const SizedBox(width: AppDimensions.spacing10),
            Text(
              label,
              style: AppTypography.buttonLarge.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
