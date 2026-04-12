import 'package:flutter/material.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final double screenPadding;

  final double cardGap;

  final double cardRadius;

  final double inputRadius;

  final Color brandAccent;

  final Color textMuted;

  final Color textFaint;

  final Color placeholder;

  const AppTokens({
    required this.screenPadding,
    required this.cardGap,
    required this.cardRadius,
    required this.inputRadius,
    required this.brandAccent,
    required this.textMuted,
    required this.textFaint,
    required this.placeholder,
  });

  static const light = AppTokens(
    screenPadding: 14,
    cardGap: 7,
    cardRadius: 12,
    inputRadius: 12,
    brandAccent: Color(0xFFE8D44D),
    textMuted: Color(0xFF757575),
    textFaint: Color(0xFFBDBDBD),
    placeholder: Color(0xFFE0E0E0),
  );

  static const dark = AppTokens(
    screenPadding: 14,
    cardGap: 7,
    cardRadius: 12,
    inputRadius: 12,
    brandAccent: Color(0xFFF0E06A),
    textMuted: Color(0xFFB0B0B0),
    textFaint: Color(0xFF616161),
    placeholder: Color(0xFF4A4A4A),
  );

  @override
  AppTokens copyWith({
    double? screenPadding,
    double? cardGap,
    double? cardRadius,
    double? inputRadius,
    Color? brandAccent,
    Color? textMuted,
    Color? textFaint,
    Color? placeholder,
  }) {
    return AppTokens(
      screenPadding: screenPadding ?? this.screenPadding,
      cardGap: cardGap ?? this.cardGap,
      cardRadius: cardRadius ?? this.cardRadius,
      inputRadius: inputRadius ?? this.inputRadius,
      brandAccent: brandAccent ?? this.brandAccent,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      placeholder: placeholder ?? this.placeholder,
    );
  }

  @override
  AppTokens lerp(covariant ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      screenPadding: lerpDouble(screenPadding, other.screenPadding, t)!,
      cardGap: lerpDouble(cardGap, other.cardGap, t)!,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      inputRadius: lerpDouble(inputRadius, other.inputRadius, t)!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
    );
  }

  static double? lerpDouble(double? a, double? b, double t) {
    if (a == null || b == null) return b;
    return a + (b - a) * t;
  }
}
