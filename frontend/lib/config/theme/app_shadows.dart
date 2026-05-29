import 'package:flutter/material.dart';

/// Elevation / shadow tokens. Use instead of inline [BoxShadow] literals.
class AppShadows {
  AppShadows._();

  /// e1 — card resting (≈1 dp).
  static const List<BoxShadow> e1 = [
    BoxShadow(
      color: Color(0x141C1917), // ink @ 8%
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// e2 — elevated card / list item (≈2–4 dp).
  static const List<BoxShadow> e2 = [
    BoxShadow(
      color: Color(0x1F1C1917), // ink @ 12%
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// e3 — modal / bottom sheet (≈8 dp).
  static const List<BoxShadow> e3 = [
    BoxShadow(
      color: Color(0x261C1917), // ink @ 15%
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// primaryGlow — FAB / publish button vermilion glow.
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x59B91C1C), // primary @ 35%
      blurRadius: 18,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x221C1917), // ink @ 13%
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
}
