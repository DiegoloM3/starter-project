import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/ui_elements/count_badge.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final int? count;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.count,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppDimensions.iconMd, color: colors.textPrimary),
          const SizedBox(width: AppDimensions.spacing8),
        ],
        Text(
          title,
          style: AppTypography.buttonLarge.copyWith(color: colors.textPrimary),
        ),
        const Spacer(),
        if (count != null) CountBadge(count: count!),
        if (trailing != null) trailing!,
      ],
    );
  }
}
