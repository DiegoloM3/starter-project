import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';

class SectionChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const SectionChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing8,
          horizontal: AppDimensions.spacing16,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentGreen : colors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: isActive ? null : Border.all(color: colors.borderSubtle),
        ),
        child: Text(
          label,
          style: AppTypography.badge.copyWith(
            color: isActive ? AppColors.white : colors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
