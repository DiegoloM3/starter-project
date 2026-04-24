import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/tokens/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/tokens/app_radii.dart';
import 'package:news_app_clean_architecture/config/theme/tokens/app_spacing.dart';

/// Semantic theme exposed to widgets via `context.appTheme`.
///
/// Widgets must consume colors/spacing/radii through this extension instead
/// of touching token files directly — that keeps swap-in dark mode and any
/// future palette changes isolated to `app_themes.dart`.
@immutable
class AppTheme extends ThemeExtension<AppTheme> {
  const AppTheme({
    required this.surface,
    required this.surfaceMuted,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.danger,
    required this.divider,
    required this.spacing,
    required this.radii,
  });

  factory AppTheme.light() => const AppTheme(
        surface: AppColors.neutral0,
        surfaceMuted: AppColors.neutral50,
        onSurface: AppColors.neutral900,
        onSurfaceMuted: AppColors.neutral500,
        primary: AppColors.brandPrimary,
        onPrimary: AppColors.neutral0,
        accent: AppColors.brandAccent,
        danger: AppColors.danger,
        divider: AppColors.neutral200,
        spacing: AppSpacingTokens(),
        radii: AppRadiiTokens(),
      );

  factory AppTheme.dark() => const AppTheme(
        surface: AppColors.neutral900,
        surfaceMuted: AppColors.neutral800,
        onSurface: AppColors.neutral0,
        onSurfaceMuted: AppColors.neutral400,
        primary: AppColors.neutral0,
        onPrimary: AppColors.neutral900,
        accent: AppColors.brandAccent,
        danger: AppColors.danger,
        divider: AppColors.neutral700,
        spacing: AppSpacingTokens(),
        radii: AppRadiiTokens(),
      );

  final Color surface;
  final Color surfaceMuted;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color danger;
  final Color divider;
  final AppSpacingTokens spacing;
  final AppRadiiTokens radii;

  @override
  AppTheme copyWith({
    Color? surface,
    Color? surfaceMuted,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? primary,
    Color? onPrimary,
    Color? accent,
    Color? danger,
    Color? divider,
    AppSpacingTokens? spacing,
    AppRadiiTokens? radii,
  }) {
    return AppTheme(
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      danger: danger ?? this.danger,
      divider: divider ?? this.divider,
      spacing: spacing ?? this.spacing,
      radii: radii ?? this.radii,
    );
  }

  @override
  AppTheme lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) return this;
    return AppTheme(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      spacing: spacing,
      radii: radii,
    );
  }
}

/// Spacing tokens grouped under the theme so widgets can reach them via
/// `context.appTheme.spacing.lg` instead of importing a constants file.
@immutable
class AppSpacingTokens {
  const AppSpacingTokens();

  double get xs => AppSpacing.xs;
  double get sm => AppSpacing.sm;
  double get md => AppSpacing.md;
  double get lg => AppSpacing.lg;
  double get xl => AppSpacing.xl;
  double get xxl => AppSpacing.xxl;
  double get xxxl => AppSpacing.xxxl;
}

@immutable
class AppRadiiTokens {
  const AppRadiiTokens();

  double get sm => AppRadii.sm;
  double get md => AppRadii.md;
  double get lg => AppRadii.lg;
  double get pill => AppRadii.pill;

  BorderRadius get smRadius => AppRadii.radiusSm;
  BorderRadius get mdRadius => AppRadii.radiusMd;
  BorderRadius get lgRadius => AppRadii.radiusLg;
}

extension AppThemeX on BuildContext {
  /// Semantic theme tokens for the current `Theme`. Falls back to the light
  /// preset if the extension isn't registered (defensive — should never
  /// trigger once `MaterialApp.theme` wires it).
  AppTheme get appTheme =>
      Theme.of(this).extension<AppTheme>() ?? AppTheme.light();
}
