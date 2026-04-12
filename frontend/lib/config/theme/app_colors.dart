import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color accentGreen = Color(0xFF3D8A5A);
  static const Color coral = Color(0xFFD89575);
  static const Color destructive = Color(0xFFD08068);
  static const Color white = Color(0xFFFFFFFF);
  static const Color frostedGlassLight = Color(0xCCFFFFFF);
  static const Color frostedGlassDark = Color(0xCC2A2928);
  static const Color deleteOverlay = Color(0xDDE53E3E);

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
  final Color frostedGlass;
  final Color accentGreenLight;

  // ── Section badge colors ───────────────────────────────────────────
  final Color weatherSectionBackground;
  final Color weatherSectionText;
  final Color politicsSectionBackground;
  final Color politicsSectionText;
  final Color artsSectionBackground;
  final Color artsSectionText;
  final Color sportsSectionBackground;
  final Color sportsSectionText;
  final Color crimeSectionBackground;
  final Color crimeSectionText;

  const AppColorsExtension({
    required this.bgPage,
    required this.bgCard,
    required this.bgInput,
    required this.textPrimary,
    required this.textSecondary,
    required this.textPlaceholder,
    required this.borderSubtle,
    required this.frostedGlass,
    required this.accentGreenLight,
    required this.weatherSectionBackground,
    required this.weatherSectionText,
    required this.politicsSectionBackground,
    required this.politicsSectionText,
    required this.artsSectionBackground,
    required this.artsSectionText,
    required this.sportsSectionBackground,
    required this.sportsSectionText,
    required this.crimeSectionBackground,
    required this.crimeSectionText,
  });

  static const light = AppColorsExtension(
    bgPage: Color(0xFFF5F4F1),
    bgCard: Color(0xFFFFFFFF),
    bgInput: Color(0xFFFAFAF8),
    textPrimary: Color(0xFF1A1918),
    textSecondary: Color(0xFF6D6C6A),
    textPlaceholder: Color(0xFF9C9B99),
    borderSubtle: Color(0xFFE5E4E1),
    frostedGlass: AppColors.frostedGlassLight,
    accentGreenLight: Color(0xFFC8F0D8),
    weatherSectionBackground: Color(0xFFE3F2FD),
    weatherSectionText: Color(0xFF1976D2),
    politicsSectionBackground: Color(0xFFFFF3E0),
    politicsSectionText: Color(0xFFE65100),
    artsSectionBackground: Color(0xFFF3E5F5),
    artsSectionText: Color(0xFF7B1FA2),
    sportsSectionBackground: Color(0xFFE8F5E9),
    sportsSectionText: Color(0xFF2E7D32),
    crimeSectionBackground: Color(0xFFFFEBEE),
    crimeSectionText: Color(0xFFC62828),
  );

  static const dark = AppColorsExtension(
    bgPage: Color(0xFF1A1918),
    bgCard: Color(0xFF2A2928),
    bgInput: Color(0xFF333231),
    textPrimary: Color(0xFFF5F4F1),
    textSecondary: Color(0xFFA8A7A5),
    textPlaceholder: Color(0xFF6D6C6A),
    borderSubtle: Color(0xFF3A3938),
    frostedGlass: AppColors.frostedGlassDark,
    accentGreenLight: Color(0xFF2A4A35),
    weatherSectionBackground: Color(0xFF1A3A5C),
    weatherSectionText: Color(0xFF64B5F6),
    politicsSectionBackground: Color(0xFF4A2E00),
    politicsSectionText: Color(0xFFFFB74D),
    artsSectionBackground: Color(0xFF3A1F4A),
    artsSectionText: Color(0xFFCE93D8),
    sportsSectionBackground: Color(0xFF1B3A1D),
    sportsSectionText: Color(0xFF81C784),
    crimeSectionBackground: Color(0xFF4A1A1A),
    crimeSectionText: Color(0xFFEF9A9A),
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
    Color? frostedGlass,
    Color? accentGreenLight,
    Color? weatherSectionBackground,
    Color? weatherSectionText,
    Color? politicsSectionBackground,
    Color? politicsSectionText,
    Color? artsSectionBackground,
    Color? artsSectionText,
    Color? sportsSectionBackground,
    Color? sportsSectionText,
    Color? crimeSectionBackground,
    Color? crimeSectionText,
  }) {
    return AppColorsExtension(
      bgPage: bgPage ?? this.bgPage,
      bgCard: bgCard ?? this.bgCard,
      bgInput: bgInput ?? this.bgInput,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textPlaceholder: textPlaceholder ?? this.textPlaceholder,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      frostedGlass: frostedGlass ?? this.frostedGlass,
      accentGreenLight: accentGreenLight ?? this.accentGreenLight,
      weatherSectionBackground: weatherSectionBackground ?? this.weatherSectionBackground,
      weatherSectionText: weatherSectionText ?? this.weatherSectionText,
      politicsSectionBackground: politicsSectionBackground ?? this.politicsSectionBackground,
      politicsSectionText: politicsSectionText ?? this.politicsSectionText,
      artsSectionBackground: artsSectionBackground ?? this.artsSectionBackground,
      artsSectionText: artsSectionText ?? this.artsSectionText,
      sportsSectionBackground: sportsSectionBackground ?? this.sportsSectionBackground,
      sportsSectionText: sportsSectionText ?? this.sportsSectionText,
      crimeSectionBackground: crimeSectionBackground ?? this.crimeSectionBackground,
      crimeSectionText: crimeSectionText ?? this.crimeSectionText,
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
      frostedGlass: Color.lerp(frostedGlass, other.frostedGlass, t)!,
      accentGreenLight:
          Color.lerp(accentGreenLight, other.accentGreenLight, t)!,
      weatherSectionBackground:
          Color.lerp(weatherSectionBackground, other.weatherSectionBackground, t)!,
      weatherSectionText:
          Color.lerp(weatherSectionText, other.weatherSectionText, t)!,
      politicsSectionBackground: Color.lerp(
          politicsSectionBackground, other.politicsSectionBackground, t)!,
      politicsSectionText:
          Color.lerp(politicsSectionText, other.politicsSectionText, t)!,
      artsSectionBackground:
          Color.lerp(artsSectionBackground, other.artsSectionBackground, t)!,
      artsSectionText:
          Color.lerp(artsSectionText, other.artsSectionText, t)!,
      sportsSectionBackground: Color.lerp(
          sportsSectionBackground, other.sportsSectionBackground, t)!,
      sportsSectionText:
          Color.lerp(sportsSectionText, other.sportsSectionText, t)!,
      crimeSectionBackground: Color.lerp(
          crimeSectionBackground, other.crimeSectionBackground, t)!,
      crimeSectionText:
          Color.lerp(crimeSectionText, other.crimeSectionText, t)!,
    );
  }
}
