import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Both themes share this builder so the pill buttons / rounded inputs /
/// FAB / dialog shapes from DESIGN.md ("Editorial Obsidian") apply
/// consistently in light and dark, instead of only being defined once and
/// forgotten for dark mode.
ThemeData _buildTheme(ColorScheme colorScheme) {
  final textTheme =
      AppTypography.textTheme(colorScheme.onSurface, colorScheme.onSurfaceVariant);

  return ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    ),
    // Every "on X" pairing below is deliberately matched to the token it
    // actually contrasts against (M3's ColorScheme.fromSeed computes each
    // "onX" specifically to stay legible against its matching X, per
    // brightness) -- an earlier pass paired primaryContainer's background
    // with onPrimary (the token meant for primary, not primaryContainer),
    // which happened to still read fine in light mode by coincidence but
    // risked low-contrast text in dark mode. Filled containers now pair
    // with their own onXContainer; plain/text-only accents use `primary`,
    // which M3 guarantees stays readable against `surface` in both modes.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const StadiumBorder(),
        textStyle: textTheme.titleMedium,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        minimumSize: const Size(48, 48),
        textStyle: textTheme.titleMedium,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.brightness == Brightness.light
          ? AppColors.lightFabTint
          : colorScheme.secondaryContainer,
      foregroundColor: colorScheme.brightness == Brightness.light
          ? colorScheme.primaryContainer
          : colorScheme.onSecondaryContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      labelStyle: textTheme.labelMedium,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      titleTextStyle: textTheme.headlineMedium,
      contentTextStyle: textTheme.bodyMedium,
    ),
  );
}

ThemeData theme() => _buildTheme(AppColors.light);

ThemeData darkTheme() => _buildTheme(AppColors.dark);
