import 'package:flutter/material.dart';

abstract final class AppTypography {
  /// Sans-serif body / UI font (already declared in pubspec.yaml).
  static const String sansFamily = 'Muli';

  /// Display family used for article headlines (declared inline by callers
  /// while we ship the font asset — see daily_news article tile/details).
  static const String displayFamily = 'Butler';

  static TextTheme buildTextTheme(ColorScheme scheme) {
    final onSurface = scheme.onSurface;
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: displayFamily,
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFamily,
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: onSurface,
      ),
      headlineSmall: TextStyle(
        fontFamily: displayFamily,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: sansFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: sansFamily,
        fontSize: 16,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: sansFamily,
        fontSize: 14,
        color: onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: sansFamily,
        fontSize: 12,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontFamily: sansFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
    );
  }
}
