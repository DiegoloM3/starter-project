import 'package:flutter/material.dart';

class AppColors {
  // Cyber Night Palette
  static const Color primary = Color(0xFF00E5FF); // Neon Cyan
  static const Color primaryGlow = Color(0x4000E5FF);
  static const Color background = Color(0xFF05050A); // Deepest Black
  static const Color surface = Color(0xFF0E0E1A); // Dark Slate Blue
  static const Color surfaceLight = Color(0xFF1A1A2E);
  static const Color accent = Color(0xFFD600FF); // Neon Purple
  
  // State colors
  static const Color highlight = Color(0xFFFF006E); // Cyber Pink
  static const Color success = Color(0xFF00FF9C);
  static const Color alert = Color(0xFFFFBE0B);

  // Text colors
  static const Color textHeadline = Colors.white;
  static const Color textBody = Color(0xFFE2E2E2);
  static const Color textMuted = Color(0xFF71718F);
  
  // Gradients
  static const Gradient cyberGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
