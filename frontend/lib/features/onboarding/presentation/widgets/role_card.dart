import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';

class RoleCard extends StatelessWidget {
  final String role;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final Color iconBackgroundColor;

  const RoleCard({
    super.key,
    required this.role,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: AppSpacing.huge,
              backgroundColor: iconBackgroundColor,
              child: Icon(icon, color: AppColors.white, size: AppSpacing.iconXl),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(label, style: AppTypography.h4),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: AppTypography.bodySm,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
