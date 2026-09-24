import 'package:flutter/material.dart';

/// The design system of `docs/FRONTEND_DESIGN.md`, in code.
///
/// Every screen reads its colours, spacing and radii from here rather than
/// writing literals, so the design has one source of truth on this side too.
abstract final class AppColors {
  static const Color accent = Color(0xFF7C3AED);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF9F8F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightText = Color(0xFF111827);
  static const Color lightTextMuted = Color(0xFF6B7280);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0B0A0F);
  static const Color darkSurface = Color(0xFF16141F);
  static const Color darkDivider = Color(0xFF2A263D);
  static const Color darkText = Color(0xFFF5F3FF);
  static const Color darkTextMuted = Color(0xFF9CA3AF);

  /// Status colours that still read apart in greyscale, so status is never
  /// carried by hue alone.
  static const Color published = Color(0xFF4B5563);
  static const Color draft = Color(0xFFE5E7EB);
}

/// The 4pt spacing scale. Used instead of loose literals so rhythm stays
/// consistent between screens.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
}

abstract final class AppRadius {
  static const double card = 16;
  static const double button = 30;
  static const double sheet = 32;

  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
}

abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 12,
      color: Color(0x0F000000),
    ),
  ];

  static const List<BoxShadow> sheet = [
    BoxShadow(
      offset: Offset(0, -10),
      blurRadius: 24,
      color: Color(0x40000000),
    ),
  ];
}
