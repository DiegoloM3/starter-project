import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ink & Paper design tokens.
class AppColors {
  AppColors._();

  static const Color bg = Color(0xFFF5F5F4);
  static const Color surface = Color(0xFFFAFAF9);
  static const Color ink = Color(0xFF1C1917);
  static const Color red = Color(0xFFB91C1C);
  static const Color border = Color(0xFFE7E5E4);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFB45309);
  static const Color info = Color(0xFF1D4ED8);

  // Text hierarchy
  static const Color t1 = Color(0xFF1C1917);
  static const Color t2 = Color(0xFF78716C);
  static const Color t3 = Color(0xFFD6D3D1);

  // Status badge palettes
  static const Color draftBg = Color(0xFFFFFBEB);
  static const Color draftFg = Color(0xFF92400E);
  static const Color draftBorder = Color(0xFFFDE68A);

  static const Color publishedBg = Color(0xFFF0FDF4);
  static const Color publishedFg = Color(0xFF15803D);
  static const Color publishedBorder = Color(0xFF86EFAC);

  static const Color archivedBg = Color(0xFFF1F5F9);
  static const Color archivedFg = Color(0xFF475569);
  static const Color archivedBorder = Color(0xFFCBD5E1);
}

class AppRadius {
  AppRadius._();

  static const double xs = 2;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 20;
}

/// Typography helpers.
///
/// [serif] → Libre Baskerville (headings, titles)
/// [sans]  → Mulish (body, UI labels)
class AppTypography {
  AppTypography._();

  static TextStyle serif({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.t1,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.libreBaskerville(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  static TextStyle sans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.t1,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.mulish(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Muli',
    appBarTheme: appBarTheme(),
    dividerColor: AppColors.border,
    colorScheme: const ColorScheme.light(
      primary: AppColors.red,
      error: AppColors.error,
      surface: AppColors.surface,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: AppTypography.sans(
        fontSize: 13.5,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    backgroundColor: AppColors.surface,
    elevation: 0,
    centerTitle: false,
    iconTheme: const IconThemeData(color: AppColors.t1),
    titleTextStyle: AppTypography.serif(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: AppColors.t1,
      letterSpacing: -0.2,
    ),
  );
}
