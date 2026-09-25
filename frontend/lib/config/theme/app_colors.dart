import 'package:flutter/material.dart';

/// Light scheme: exact values from the "Editorial Obsidian" design system
/// (DESIGN.md, generated from screenshots of this app). Dark scheme: NOT
/// specified in DESIGN.md -- it only defines one warm/paper palette meant
/// for daylight reading ("Warm Tactility: Crisp paper surfaces... simulate
/// natural daylight reading"). Rather than inventing ~30 dark color values
/// by guessing, the dark scheme is derived from the same primary indigo
/// seed via Material 3's own tonal-palette algorithm (ColorScheme.fromSeed),
/// which guarantees accessible contrast and keeps the same brand hue.
class AppColors {
  AppColors._();

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF3525CD),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF4F46E5),
    onPrimaryContainer: Color(0xFFDAD7FF),
    primaryFixed: Color(0xFFE2DFFF),
    primaryFixedDim: Color(0xFFC3C0FF),
    onPrimaryFixed: Color(0xFF0F0069),
    onPrimaryFixedVariant: Color(0xFF3323CC),
    secondary: Color(0xFF4648D4),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF6063EE),
    onSecondaryContainer: Color(0xFFFFFBFF),
    secondaryFixed: Color(0xFFE1E0FF),
    secondaryFixedDim: Color(0xFFC0C1FF),
    onSecondaryFixed: Color(0xFF07006C),
    onSecondaryFixedVariant: Color(0xFF2F2EBE),
    tertiary: Color(0xFF434853),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF5B606B),
    onTertiaryContainer: Color(0xFFD7DBE8),
    tertiaryFixed: Color(0xFFDEE2EF),
    tertiaryFixedDim: Color(0xFFC2C6D3),
    onTertiaryFixed: Color(0xFF171C25),
    onTertiaryFixedVariant: Color(0xFF424751),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFF8F9FF),
    onSurface: Color(0xFF191C20),
    surfaceDim: Color(0xFFD8DADF),
    surfaceBright: Color(0xFFF8F9FF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF2F3F9),
    surfaceContainer: Color(0xFFECEEF3),
    surfaceContainerHigh: Color(0xFFE6E8EE),
    surfaceContainerHighest: Color(0xFFE1E2E8),
    onSurfaceVariant: Color(0xFF464555),
    outline: Color(0xFF777587),
    outlineVariant: Color(0xFFC7C4D8),
    inverseSurface: Color(0xFF2E3135),
    onInverseSurface: Color(0xFFEFF0F6),
    inversePrimary: Color(0xFFC3C0FF),
    surfaceTint: Color(0xFF4D44E3),
  );

  static const Color primarySeed = Color(0xFF4F46E5);

  /// DESIGN.md's "Tertiary Tint" -- the soft lavender used specifically for
  /// FAB containers and active chip backgrounds in light mode. Not part of
  /// ColorScheme's own token set, so it's kept as a standalone constant
  /// instead of forced into one of ColorScheme's named slots.
  static const Color lightFabTint = Color(0xFFEEF2FF);

  /// The "breaking news" ticker's own band, fixed regardless of light/dark
  /// mode. `colorScheme.inverseSurface` looked right for this in light mode
  /// by coincidence -- it's a dark tone there -- but it's defined to invert
  /// WITH the theme, so in dark mode it turns light, leaving the ticker
  /// looking unchanged from light mode instead of staying the bold band
  /// it's meant to always be. Went through a bright red, a deep indigo,
  /// and neutral gray before Jano pointed at a reference redesign
  /// ("Feed Editorial con Breaking News") using this specific wine/crimson
  /// for its own "BREAKING" band -- matched to that reference directly.
  static const Color tickerSurface = Color(0xFF8B1E41);
  static const Color onTickerSurface = Color(0xFFFFFFFF);

  static ColorScheme get dark => ColorScheme.fromSeed(
        seedColor: primarySeed,
        brightness: Brightness.dark,
      );
}
