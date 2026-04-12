import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color accentGreen = Color(0xFF3D8A5A);
  static const Color coral = Color(0xFFD89575);
  static const Color destructive = Color(0xFFD08068);
  static const Color white = Color(0xFFFFFFFF);
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
  final Color accentGreenLight;

  // ── Section badge colors ───────────────────────────────────────────
  final Color sectionClimaBackground;
  final Color sectionClimaText;
  final Color sectionPoliticaBackground;
  final Color sectionPoliticaText;
  final Color sectionArtesBackground;
  final Color sectionArtesText;
  final Color sectionDeportesBackground;
  final Color sectionDeportesText;
  final Color sectionPoliciacaBackground;
  final Color sectionPoliciacaText;

  const AppColorsExtension({
    required this.bgPage,
    required this.bgCard,
    required this.bgInput,
    required this.textPrimary,
    required this.textSecondary,
    required this.textPlaceholder,
    required this.borderSubtle,
    required this.accentGreenLight,
    required this.sectionClimaBackground,
    required this.sectionClimaText,
    required this.sectionPoliticaBackground,
    required this.sectionPoliticaText,
    required this.sectionArtesBackground,
    required this.sectionArtesText,
    required this.sectionDeportesBackground,
    required this.sectionDeportesText,
    required this.sectionPoliciacaBackground,
    required this.sectionPoliciacaText,
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
    sectionClimaBackground: Color(0xFFE3F2FD),
    sectionClimaText: Color(0xFF1976D2),
    sectionPoliticaBackground: Color(0xFFFFF3E0),
    sectionPoliticaText: Color(0xFFE65100),
    sectionArtesBackground: Color(0xFFF3E5F5),
    sectionArtesText: Color(0xFF7B1FA2),
    sectionDeportesBackground: Color(0xFFE8F5E9),
    sectionDeportesText: Color(0xFF2E7D32),
    sectionPoliciacaBackground: Color(0xFFFFEBEE),
    sectionPoliciacaText: Color(0xFFC62828),
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
    sectionClimaBackground: Color(0xFF1A3A5C),
    sectionClimaText: Color(0xFF64B5F6),
    sectionPoliticaBackground: Color(0xFF4A2E00),
    sectionPoliticaText: Color(0xFFFFB74D),
    sectionArtesBackground: Color(0xFF3A1F4A),
    sectionArtesText: Color(0xFFCE93D8),
    sectionDeportesBackground: Color(0xFF1B3A1D),
    sectionDeportesText: Color(0xFF81C784),
    sectionPoliciacaBackground: Color(0xFF4A1A1A),
    sectionPoliciacaText: Color(0xFFEF9A9A),
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
    Color? sectionClimaBackground,
    Color? sectionClimaText,
    Color? sectionPoliticaBackground,
    Color? sectionPoliticaText,
    Color? sectionArtesBackground,
    Color? sectionArtesText,
    Color? sectionDeportesBackground,
    Color? sectionDeportesText,
    Color? sectionPoliciacaBackground,
    Color? sectionPoliciacaText,
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
      sectionClimaBackground:
          sectionClimaBackground ?? this.sectionClimaBackground,
      sectionClimaText: sectionClimaText ?? this.sectionClimaText,
      sectionPoliticaBackground:
          sectionPoliticaBackground ?? this.sectionPoliticaBackground,
      sectionPoliticaText: sectionPoliticaText ?? this.sectionPoliticaText,
      sectionArtesBackground:
          sectionArtesBackground ?? this.sectionArtesBackground,
      sectionArtesText: sectionArtesText ?? this.sectionArtesText,
      sectionDeportesBackground:
          sectionDeportesBackground ?? this.sectionDeportesBackground,
      sectionDeportesText: sectionDeportesText ?? this.sectionDeportesText,
      sectionPoliciacaBackground:
          sectionPoliciacaBackground ?? this.sectionPoliciacaBackground,
      sectionPoliciacaText: sectionPoliciacaText ?? this.sectionPoliciacaText,
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
      sectionClimaBackground:
          Color.lerp(sectionClimaBackground, other.sectionClimaBackground, t)!,
      sectionClimaText:
          Color.lerp(sectionClimaText, other.sectionClimaText, t)!,
      sectionPoliticaBackground: Color.lerp(
          sectionPoliticaBackground, other.sectionPoliticaBackground, t)!,
      sectionPoliticaText:
          Color.lerp(sectionPoliticaText, other.sectionPoliticaText, t)!,
      sectionArtesBackground:
          Color.lerp(sectionArtesBackground, other.sectionArtesBackground, t)!,
      sectionArtesText:
          Color.lerp(sectionArtesText, other.sectionArtesText, t)!,
      sectionDeportesBackground: Color.lerp(
          sectionDeportesBackground, other.sectionDeportesBackground, t)!,
      sectionDeportesText:
          Color.lerp(sectionDeportesText, other.sectionDeportesText, t)!,
      sectionPoliciacaBackground: Color.lerp(
          sectionPoliciacaBackground, other.sectionPoliciacaBackground, t)!,
      sectionPoliciacaText:
          Color.lerp(sectionPoliciacaText, other.sectionPoliciacaText, t)!,
    );
  }
}
