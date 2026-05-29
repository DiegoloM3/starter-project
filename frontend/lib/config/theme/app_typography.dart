import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The full Material 3 type scale, mapped to the Ink & Paper pairing.
/// No colors are set so each role inherits `colorScheme.onSurface`.
TextTheme buildAppTextTheme() {
  TextStyle serif({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.libreBaskerville(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
      );

  TextStyle sans({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.mulish(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
      );

  return TextTheme(
    // Display — page mastheads, brand headers.
    displayLarge:
        serif(fontSize: 48, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -0.8),
    displayMedium:
        serif(fontSize: 36, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.5),
    displaySmall:
        serif(fontSize: 28, fontWeight: FontWeight.w700, height: 1.18, letterSpacing: -0.3),

    // Headline — article titles, screen headings.
    headlineLarge:
        serif(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.3),
    headlineMedium:
        serif(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.3),
    headlineSmall:
        serif(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: -0.2),

    // Title — AppBar, section headers, card sub-headings (Mulish).
    titleLarge:
        sans(fontSize: 17, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.2),
    titleMedium:
        sans(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: 0.0),
    titleSmall:
        sans(fontSize: 13, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: 0.0),

    // Body — bodyLarge = editorial article body (serif); rest = UI (Mulish).
    bodyLarge:
        serif(fontSize: 16, fontWeight: FontWeight.w400, height: 1.82, letterSpacing: 0.0),
    bodyMedium:
        sans(fontSize: 14, fontWeight: FontWeight.w400, height: 1.55, letterSpacing: 0.0),
    bodySmall:
        sans(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.0),

    // Label — button text, meta, overline/badges.
    labelLarge:
        sans(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.4, letterSpacing: 0.3),
    labelMedium:
        sans(fontSize: 11.0, fontWeight: FontWeight.w700, height: 1.4, letterSpacing: 0.8),
    labelSmall:
        sans(fontSize: 9.5, fontWeight: FontWeight.w800, height: 1.4, letterSpacing: 1.8),
  );
}
