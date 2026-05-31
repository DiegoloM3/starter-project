import 'package:flutter/material.dart';

/// Centralized color palette — Symmetry News (Stitch design tokens).
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF9E0000);
  static const Color primaryContainer = Color(0xFFCC0000);

  // Backgrounds
  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);

  // Text
  static const Color textPrimary = Color(0xFF1A1C1C);
  static const Color textSecondary = Color(0xFF5E3F3A);
  static const Color textHint = Color(0xFF926E69);

  // Outline
  static const Color outline = Color(0xFF926E69);
  static const Color outlineVariant = Color(0xFFE8BDB6);

  // Utility
  static const Color divider = Color(0xFFE8BDB6);
  static const Color cardShadow = Color(0x0F000000);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFF9E0000);

  // Aliases kept for backwards compat
  static const Color accent = primary;
  static const Color highlight = primary;
}
