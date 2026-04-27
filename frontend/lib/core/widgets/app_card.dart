import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';

enum AppCardVariant { light, dark }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.light,
    this.isSelected = false,
    this.onTap,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final AppCardVariant variant;
  final bool isSelected;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 12.r;
    final effectivePadding =
        padding ?? EdgeInsets.all(AppMetrics.w(16));

    final Color backgroundColor;
    final Color borderColor;

    if (isSelected) {
      backgroundColor = AppColors.accentLight;
      borderColor = AppColors.accent;
    } else {
      backgroundColor = variant == AppCardVariant.light
          ? AppColors.background
          : AppColors.surface;
      borderColor = AppColors.border;
    }

    final boxShadow = !isSelected && variant == AppCardVariant.light
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : null;

    final content = Padding(
      padding: effectivePadding,
      child: child,
    );

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: boxShadow,
      ),
      child: content,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
