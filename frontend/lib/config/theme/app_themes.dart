import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme_extension.dart';
import 'package:news_app_clean_architecture/config/theme/tokens/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/tokens/app_typography.dart';

/// Legacy entry point kept only so `app.dart` keeps compiling between
/// the theme rebuild (B3.3) and the `MaterialApp.router` migration (B3.5).
/// Delete once `lightTheme()`/`darkTheme()` are wired in directly.
@Deprecated('Use lightTheme() / darkTheme() — removed in B3.5.')
ThemeData theme() => lightTheme();

ThemeData lightTheme() {
  final appTheme = AppTheme.light();
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.brandPrimary,
    primary: appTheme.primary,
    onPrimary: appTheme.onPrimary,
    surface: appTheme.surface,
    onSurface: appTheme.onSurface,
    error: appTheme.danger,
  );
  return _materialThemeFrom(scheme: scheme, appTheme: appTheme);
}

ThemeData darkTheme() {
  final appTheme = AppTheme.dark();
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.brandPrimary,
    brightness: Brightness.dark,
    primary: appTheme.primary,
    onPrimary: appTheme.onPrimary,
    surface: appTheme.surface,
    onSurface: appTheme.onSurface,
    error: appTheme.danger,
  );
  return _materialThemeFrom(scheme: scheme, appTheme: appTheme);
}

ThemeData _materialThemeFrom({
  required ColorScheme scheme,
  required AppTheme appTheme,
}) {
  final textTheme = AppTypography.buildTextTheme(scheme);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: appTheme.surface,
    fontFamily: AppTypography.sansFamily,
    textTheme: textTheme,
    dividerColor: appTheme.divider,
    iconTheme: IconThemeData(color: appTheme.onSurfaceMuted),
    appBarTheme: AppBarTheme(
      backgroundColor: appTheme.surface,
      foregroundColor: appTheme.onSurfaceMuted,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: appTheme.onSurfaceMuted),
      titleTextStyle: textTheme.titleMedium?.copyWith(
        color: appTheme.onSurfaceMuted,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: appTheme.primary,
      foregroundColor: appTheme.onPrimary,
    ),
    extensions: <ThemeExtension<dynamic>>[appTheme],
  );
}
