import 'package:flutter/material.dart';

/// Raw color palette (primitives only).
///
/// Treat these as the design system's *atoms*. UI code MUST NOT consume
/// them directly — go through `AppTheme` (semantic tokens) so that swapping
/// the palette propagates without touching widgets.
abstract final class AppColors {
  // Brand
  static const Color brandPrimary = Color(0xFF1F2937);
  static const Color brandPrimaryLight = Color(0xFF4B5563);
  static const Color brandAccent = Color(0xFFE63946);

  // Neutrals (greyscale ramp)
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF8B8B8B);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);

  // Semantic statuses
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF3B82F6);
}
