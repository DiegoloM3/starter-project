import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color accentGreen = Color(0xFF3D8A5A);
  static const Color coral = Color(0xFFD89575);
  static const Color destructive = Color(0xFFD08068);
  static const Color white = Color(0xFFFFFFFF);

  // ── Shadow colors ────────────────────────────────────────────────
  static const Color shadowGreenLight = Color(0x403D8A5A);
  static const Color shadowGreenStrong = Color(0x503D8A5A);
  static const Color shadowDarkSubtle = Color(0x081A1918);
  static const Color shadowDarkLight = Color(0x101A1918);
  static const Color shadowDarkMedium = Color(0x141A1918);
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color bgPage;
  final Color bgCard;
  final Color bgInput;
  final Color textPrimary;
  final Color textSecondary;
  final Color textPlaceholder;
  final Color borderSubtle;
  final Color accentGreenLight;

  const AppColorsExtension({
    required this.bgPage,
    required this.bgCard,
    required this.bgInput,
    required this.textPrimary,
    required this.textSecondary,
    required this.textPlaceholder,
    required this.borderSubtle,
    required this.accentGreenLight,
  });

  static const light = AppColorsExtension(
    bgPage: Color(0xFFF5F4F1),
    bgCard: Color(0xFFFFFFFF),
    bgInput: Color(0xFFFAFAF8),
    textPrimary: Color(0xFF1A1918),
    textSecondary: Color(0xFF6D6C6A),
    textPlaceholder: Color(0xFF9C9B99),
    borderSubtle: Color(0xFFE5E4E1),
    accentGreenLight: Color(0xFFC8F0D8),
  );

  static const dark = AppColorsExtension(
    bgPage: Color(0xFF1A1918),
    bgCard: Color(0xFF2A2928),
    bgInput: Color(0xFF333231),
    textPrimary: Color(0xFFF5F4F1),
    textSecondary: Color(0xFFA8A7A5),
    textPlaceholder: Color(0xFF6D6C6A),
    borderSubtle: Color(0xFF3A3938),
    accentGreenLight: Color(0xFF2A4A35),
  );

  @override
  AppColorsExtension copyWith({
    Color? bgPage,
    Color? bgCard,
    Color? bgInput,
    Color? textPrimary,
    Color? textSecondary,
    Color? textPlaceholder,
    Color? borderSubtle,
    Color? accentGreenLight,
  }) {
    return AppColorsExtension(
      bgPage: bgPage ?? this.bgPage,
      bgCard: bgCard ?? this.bgCard,
      bgInput: bgInput ?? this.bgInput,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textPlaceholder: textPlaceholder ?? this.textPlaceholder,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      accentGreenLight: accentGreenLight ?? this.accentGreenLight,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      bgPage: Color.lerp(bgPage, other.bgPage, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgInput: Color.lerp(bgInput, other.bgInput, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      accentGreenLight:
          Color.lerp(accentGreenLight, other.accentGreenLight, t)!,
    );
  }
}
