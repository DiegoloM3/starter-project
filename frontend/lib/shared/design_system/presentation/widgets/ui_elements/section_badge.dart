import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

class SectionBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const SectionBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacing4,
        horizontal: AppDimensions.spacing10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: AppTypography.badgeSmall.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}
