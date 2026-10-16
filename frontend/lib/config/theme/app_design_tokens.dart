import 'package:flutter/material.dart';

/// Values taken from the Figma prototype (SVG export of the screens).
class AppColors {
  static const Color lilac = Color(0xFFE1BEE0);
  static const Color darkText = Color(0xFF2C2C2C);
  static const Color inputBorder = Color(0x33000000);
  static const Color hintText = Color(0x80000000);
  static const Color contentText = Color(0xE6000000);
  static const Color error = Color(0xFFB3261E);
}

class AppFonts {
  static const String inter = 'Inter';
}

class AppShadows {
  static const Color _shadowColor = Color(0x40000000);

  /// Figma "drop shadow" blur values are twice the Gaussian standard
  /// deviation, while Flutter's blur radius maps to a sigma of
  /// `radius * 0.57735 + 0.5`.
  static double _convertFigmaBlurToRadius(double figmaBlur) {
    return (figmaBlur / 2 - 0.5) / 0.57735;
  }

  static final List<BoxShadow> raisedButton = [
    BoxShadow(color: _shadowColor, offset: const Offset(0, 4), blurRadius: _convertFigmaBlurToRadius(4)),
    BoxShadow(color: _shadowColor, offset: const Offset(0, 4), blurRadius: _convertFigmaBlurToRadius(24)),
  ];

  static final List<BoxShadow> floatingButton = [
    BoxShadow(color: _shadowColor, offset: const Offset(0, 4), blurRadius: _convertFigmaBlurToRadius(4)),
    BoxShadow(color: const Color(0x4F000000), offset: const Offset(0, 4), blurRadius: _convertFigmaBlurToRadius(17)),
  ];
}

class AppRadius {
  static const BorderRadius standard = BorderRadius.all(Radius.circular(8));
}
