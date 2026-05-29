import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Material 3 [ColorScheme] — light mode only.
///
/// Assigned to [ThemeData.colorScheme]. Built with the const `ColorScheme.light`
/// constructor so every role not listed here falls back to an M3-compliant
/// default. Widgets read these via `Theme.of(context).colorScheme`.
const ColorScheme appColorScheme = ColorScheme.light(
  // Primary (Vermilion)
  primary: AppColors.primary,
  onPrimary: AppColors.onPrimary,
  primaryContainer: AppColors.primaryContainer,
  onPrimaryContainer: AppColors.onPrimaryContainer,

  // Secondary (Warm Stone)
  secondary: AppColors.secondary,
  onSecondary: AppColors.onSecondary,
  secondaryContainer: AppColors.secondaryContainer,
  onSecondaryContainer: AppColors.onSecondaryContainer,

  // Tertiary (Amber)
  tertiary: AppColors.tertiary,
  onTertiary: AppColors.onTertiary,
  tertiaryContainer: AppColors.tertiaryContainer,
  onTertiaryContainer: AppColors.onTertiaryContainer,

  // Error
  error: AppColors.error,
  onError: AppColors.onError,
  errorContainer: AppColors.errorContainer,
  onErrorContainer: AppColors.onErrorContainer,

  // Surface & background
  surface: AppColors.surface,
  onSurface: AppColors.onSurface,
  surfaceContainerLowest: AppColors.surfaceContainerLowest,
  surfaceContainerLow: AppColors.surfaceContainerLow,
  surfaceContainer: AppColors.surfaceContainer,
  surfaceContainerHigh: AppColors.surfaceContainerHigh,
  surfaceContainerHighest: AppColors.surfaceContainerHighest,
  onSurfaceVariant: AppColors.onSurfaceVariant,

  // Outline
  outline: AppColors.outline,
  outlineVariant: AppColors.outlineVariant,

  // Inverse (snackbars, tooltips)
  inverseSurface: AppColors.inverseSurface,
  onInverseSurface: AppColors.onInverseSurface,
  inversePrimary: AppColors.inversePrimary,

  // Misc
  shadow: AppColors.shadow,
  scrim: AppColors.scrim,
  surfaceTint: AppColors.surfaceTint,
);
