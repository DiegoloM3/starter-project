import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';

class AgeRangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AgeRangeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: selected
              ? null
              : Border.all(color: AppColors.border, width: 1),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: selected ? AppColors.textOnDark : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
