import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';

class PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onPressed;

  const PillButton({
    super.key,
    required this.label,
    required this.icon,
    this.filled = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        filled ? AppColors.accentGreen : context.colors.accentGreenLight;
    final fgColor = filled ? AppColors.white : AppColors.accentGreen;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing10,
          horizontal: AppDimensions.spacing16,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppDimensions.iconSm, color: fgColor),
            const SizedBox(width: AppDimensions.spacing10),
            Text(
              label,
              style: AppTypography.pillLabel.copyWith(color: fgColor),
            ),
          ],
        ),
      ),
    );
  }
}
