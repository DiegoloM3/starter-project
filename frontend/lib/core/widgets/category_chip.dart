import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import 'app_card.dart';
import 'app_text.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String category;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.accent : AppColors.textSecondary;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: AppMetrics.w(56)),
      child: IntrinsicWidth(
        child: AppCard(
          variant: AppCardVariant.light,
          isSelected: isActive,
          onTap: onTap,
          padding: EdgeInsets.symmetric(
            horizontal: AppMetrics.w(12),
            vertical: AppMetrics.h(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20.r, color: color),
              SizedBox(height: AppMetrics.h(4)),
              AppText(
                category,
                variant: AppTextVariant.labelSmall,
                color: color,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
