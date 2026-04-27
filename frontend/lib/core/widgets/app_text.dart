import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppTextVariant {
  displayLarge,
  displayMedium,
  headlineLarge,
  headlineMedium,
  titleLarge,
  titleMedium,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelSmall,
}

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    required this.variant,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  TextStyle get _baseStyle {
    switch (variant) {
      case AppTextVariant.displayLarge:
        return AppTypography.displayLarge;
      case AppTextVariant.displayMedium:
        return AppTypography.displayMedium;
      case AppTextVariant.headlineLarge:
        return AppTypography.headlineLarge;
      case AppTextVariant.headlineMedium:
        return AppTypography.headlineMedium;
      case AppTextVariant.titleLarge:
        return AppTypography.titleLarge;
      case AppTextVariant.titleMedium:
        return AppTypography.titleMedium;
      case AppTextVariant.bodyLarge:
        return AppTypography.bodyLarge;
      case AppTextVariant.bodyMedium:
        return AppTypography.bodyMedium;
      case AppTextVariant.bodySmall:
        return AppTypography.bodySmall;
      case AppTextVariant.labelLarge:
        return AppTypography.labelLarge;
      case AppTextVariant.labelSmall:
        return AppTypography.labelSmall;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = color != null
        ? _baseStyle.copyWith(color: color)
        : _baseStyle.copyWith(color: _baseStyle.color ?? AppColors.textPrimary);

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
