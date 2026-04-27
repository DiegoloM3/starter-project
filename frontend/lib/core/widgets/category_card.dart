import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import 'app_card.dart';
import 'app_text.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String category;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contentColor =
        isSelected ? AppColors.accent : AppColors.textSecondary;

    return AppCard(
      variant: AppCardVariant.light,
      isSelected: isSelected,
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: AppMetrics.w(12),
        vertical: AppMetrics.h(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24.r, color: contentColor),
          SizedBox(height: AppMetrics.h(6)),
          AppText(
            category,
            variant: AppTextVariant.labelLarge,
            color: contentColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
