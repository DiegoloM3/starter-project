import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Title in capitals and one-line subtitle that open every account form.
class AuthFormHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthFormHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: AppTypography.tabTitle.copyWith(color: palette.ink)),
        const SizedBox(height: AppSpacing.sm),
        Text(subtitle, style: AppTypography.bodySmall.copyWith(color: palette.inkBody)),
      ],
    );
  }
}
