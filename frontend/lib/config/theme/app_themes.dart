import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/design_system.dart';

/// Application theme data Symmetry News design system.
/// Headlines: Newsreader (serif). Body: Work Sans.
abstract final class AppTheme {
  static TextTheme get _textTheme => GoogleFonts.workSansTextTheme().copyWith(
    displayLarge: GoogleFonts.newsreader(
      fontSize: 57,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: GoogleFonts.newsreader(
      fontSize: 45,
      fontWeight: FontWeight.w700,
    ),
    displaySmall: GoogleFonts.newsreader(
      fontSize: 36,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: GoogleFonts.newsreader(
      fontSize: 32,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: GoogleFonts.newsreader(
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: GoogleFonts.newsreader(
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: GoogleFonts.newsreader(
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: GoogleFonts.workSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.workSans(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: GoogleFonts.workSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      // color heredado de ColorScheme.onSurfaceVariant
    ),
    labelLarge: GoogleFonts.workSans(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    ),
    labelSmall: GoogleFonts.workSans(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      // color heredado de ColorScheme.onSurfaceVariant
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: _textTheme,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      error: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.outline,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.newsreader(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: GoogleFonts.workSans(color: AppColors.textHint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: GoogleFonts.workSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.outline),
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: GoogleFonts.workSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.workSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.outlineVariant,
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
