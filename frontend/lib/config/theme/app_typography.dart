import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static final TextStyle _base = GoogleFonts.outfit();

  static final TextStyle screenTitle = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static final TextStyle sectionTitle = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static final TextStyle userName =
      _base.copyWith(fontSize: 20, fontWeight: FontWeight.w600);

  static final TextStyle buttonLarge =
      _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600);

  static final TextStyle cardTitle = _base.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static final TextStyle body =
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w400);

  static final TextStyle bodyMedium =
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600);

  static final TextStyle compactTitle =
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w600);

  static final TextStyle label =
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w500);

  static final TextStyle subtitle = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static final TextStyle pillLabel =
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600);

  static final TextStyle badge =
      _base.copyWith(fontSize: 13, fontWeight: FontWeight.w600);

  static final TextStyle badgeSmall =
      _base.copyWith(fontSize: 11, fontWeight: FontWeight.w600);

  static final TextStyle fieldLabel = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static final TextStyle footnote =
      _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400);

  static final TextStyle tabLabel =
      _base.copyWith(fontSize: 10, fontWeight: FontWeight.w500);

  static final TextTheme textTheme = GoogleFonts.outfitTextTheme();
}
