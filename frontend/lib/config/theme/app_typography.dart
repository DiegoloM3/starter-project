import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DESIGN.md gives lineHeight in absolute px and letterSpacing in em, but
/// Flutter's TextStyle.height is a MULTIPLIER of fontSize and letterSpacing
/// is in logical px -- every value below is converted (px / fontSize, and
/// em * fontSize), not copied directly, otherwise line spacing would render
/// roughly 20x too large.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      displayLarge: GoogleFonts.newsreader(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        height: 48 / 40,
        letterSpacing: -0.02 * 40,
        color: onSurface,
      ),
      headlineLarge: GoogleFonts.newsreader(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.01 * 24,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.newsreader(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 28 / 17,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 24 / 15,
        color: onSurfaceVariant,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
        letterSpacing: 0.01 * 13,
        color: onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 14 / 11,
        letterSpacing: 0.04 * 11,
        color: onSurfaceVariant,
      ),
    );
  }
}
