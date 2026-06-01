import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final bool selected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('food') || lower.contains('comida')) {
      return Icons.restaurant;
    }
    if (lower.contains('fitness')) return Icons.fitness_center;
    if (lower.contains('mental') || lower.contains('salud mental')) {
      return Icons.self_improvement;
    }
    if (lower.contains('habit') || lower.contains('hábito')) {
      return Icons.repeat;
    }
    if (lower.contains('sleep') || lower.contains('sueño')) {
      return Icons.bedtime;
    }
    if (lower.contains('product') || lower.contains('productividad')) {
      return Icons.rocket_launch;
    }
    return Icons.star;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _iconForCategory(category.name),
                    size: AppSpacing.iconLg,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    category.name,
                    style: AppTypography.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (selected)
              const Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: AppSpacing.iconSm,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
