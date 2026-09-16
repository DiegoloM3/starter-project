import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_transitions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Builds the Material 3 themes from the design tokens: square shapes, 2px
/// rules, block buttons, one typeface.
abstract final class AppTheme {
  static ThemeData light() => _build(AppPalette.light, Brightness.light);

  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static const RoundedRectangleBorder square = RoundedRectangleBorder();

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: isDark ? p.background : p.background,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: p.onPrimaryContainer,
      secondary: p.ink,
      onSecondary: p.background,
      secondaryContainer: p.surface,
      onSecondaryContainer: p.ink,
      tertiary: p.success,
      onTertiary: Colors.white,
      tertiaryContainer: p.successContainer,
      onTertiaryContainer: p.onSuccessContainer,
      error: p.error,
      onError: Colors.white,
      errorContainer: p.errorContainer,
      onErrorContainer: p.error,
      surface: p.background,
      onSurface: p.ink,
      surfaceContainerLowest: p.tint,
      surfaceContainerLow: p.background,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surface,
      surfaceContainerHighest: p.surface,
      onSurfaceVariant: p.inkSecondary,
      outline: p.outlineStrong,
      outlineVariant: p.outline,
      shadow: Colors.black,
      scrim: p.ink,
      inverseSurface: p.ink,
      onInverseSurface: p.background,
      inversePrimary: p.primaryContainer,
    );

    final textTheme = AppTypography.textTheme(p.ink, p.inkBody, p.inkSecondary);
    final rule = BorderSide(color: p.outlineStrong, width: AppRules.strong);
    final inkRule = BorderSide(color: p.ink, width: AppRules.strong);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      fontFamily: AppTypography.family,
      textTheme: textTheme,
      extensions: [p],
      splashFactory: NoSplash.splashFactory,
      highlightColor: p.ink.withValues(alpha: 0.07),
      dividerTheme: DividerThemeData(color: p.outlineStrong, thickness: AppRules.strong, space: AppRules.strong),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.button),
          shape: square,
          textStyle: AppTypography.button,
          backgroundColor: p.primary,
          foregroundColor: p.background,
          disabledBackgroundColor: p.outline,
          disabledForegroundColor: p.inkSecondary,
          elevation: 0,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed) ? p.ink.withValues(alpha: 0.18) : null,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.button),
          shape: square,
          textStyle: AppTypography.button,
          foregroundColor: p.ink,
          side: inkRule,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSizes.touchTarget, AppSizes.touchTarget),
          shape: square,
          textStyle: AppTypography.buttonSecondary,
          foregroundColor: p.primaryDeep,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.background,
        elevation: 0,
        highlightElevation: 0,
        extendedTextStyle: AppTypography.button,
        shape: square,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.tint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: AppTypography.valueLine.copyWith(color: p.inkSecondary, fontWeight: FontWeight.w400),
        border: _fieldBorder(p.outlineStrong),
        enabledBorder: _fieldBorder(p.outlineStrong),
        focusedBorder: _fieldBorder(p.ink),
        errorBorder: _fieldBorder(p.error),
        focusedErrorBorder: _fieldBorder(p.error),
        errorStyle: const TextStyle(height: 0, fontSize: 0),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: AppTypography.bodySmall.copyWith(color: p.background, fontWeight: FontWeight.w600),
        actionTextColor: isDark ? p.primary : const Color(0xFFFF9783),
        behavior: SnackBarBehavior.floating,
        shape: square,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(side: inkRule),
        titleTextStyle: textTheme.headlineMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(side: BorderSide(color: p.ink, width: AppRules.strong)),
        dragHandleColor: p.ink,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.background,
        selectedColor: p.ink,
        side: rule,
        shape: square,
        labelStyle: AppTypography.buttonSecondary.copyWith(color: p.ink),
        secondaryLabelStyle: AppTypography.buttonSecondary.copyWith(color: p.background),
        showCheckmark: false,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: p.ink,
          selectedForegroundColor: p.background,
          foregroundColor: p.ink,
          side: inkRule,
          shape: square,
          textStyle: AppTypography.buttonSecondary,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary, linearTrackColor: p.outline),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.primary,
        inactiveTrackColor: p.outlineStrong,
        thumbColor: p.primary,
        trackHeight: 2,
        overlayColor: p.primary.withValues(alpha: 0.12),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.ink,
        textColor: p.ink,
        minVerticalPadding: 12,
        shape: square,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(side: rule),
      ),
      iconTheme: IconThemeData(color: p.ink, size: AppSizes.icon),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: EditorialPageTransitionsBuilder(),
          TargetPlatform.iOS: EditorialPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: color, width: AppRules.strong),
    );
  }
}
