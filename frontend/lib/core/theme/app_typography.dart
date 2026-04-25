import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Text style definitions for the app's type scale.
///
/// Headings (display*, headline*, title*) — DM Sans, bold/black weight.
/// Body & UI (body*, label*)            — Plus Jakarta Sans, regular/medium/semibold.
///
/// All sizes are in [sp] units (flutter_screenutil) so they scale with the
/// device's font-accessibility setting.
class AppTypography {
  AppTypography._();

  // ── Headings: DM Sans ────────────────────────────────────────────────────

  static TextStyle get displayLarge => GoogleFonts.dmSans(
        fontSize: 57.sp,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        height: 1.12,
      );

  static TextStyle get displayMedium => GoogleFonts.dmSans(
        fontSize: 45.sp,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        height: 1.16,
      );

  static TextStyle get headlineLarge => GoogleFonts.dmSans(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  static TextStyle get headlineMedium => GoogleFonts.dmSans(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.29,
      );

  static TextStyle get titleLarge => GoogleFonts.dmSans(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.27,
      );

  static TextStyle get titleMedium => GoogleFonts.dmSans(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.5,
        letterSpacing: 0.15,
      );

  // ── Body & UI: Plus Jakarta Sans ─────────────────────────────────────────

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
        letterSpacing: 0.15,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.43,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.33,
        letterSpacing: 0.4,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.43,
        letterSpacing: 0.1,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.45,
        letterSpacing: 0.5,
      );
}
