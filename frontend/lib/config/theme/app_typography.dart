import 'package:flutter/material.dart';

/// Type scale of the Headline News UI system.
///
/// One typeface, DM Sans (variable), at every size. Headlines are heavy
/// (800–900), tight and set in capitals by the widgets that use them; kickers
/// and meta lines are small capitals with wide tracking; running text is
/// regular weight. Sizes are in logical pixels and scale with the user's
/// text-size setting through [MediaQuery.textScaler].
abstract final class AppTypography {
  static const String family = 'DM Sans';

  static TextStyle _style(
    double size,
    double lineHeight, {
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      // The asset is a variable font: the weight axis has to be driven
      // explicitly, `fontWeight` alone would only pick a static face.
      fontVariations: [FontVariation.weight(weight.value.toDouble())],
    );
  }

  /// Tracking as a fraction of the size, the way the design specifies it.
  static double _em(double size, double em) => size * em;

  // Headings: capitals, heavy, tight.
  static final TextStyle display = _style(40, 36, weight: FontWeight.w900, letterSpacing: _em(40, -0.045));
  static final TextStyle wordmark = display;
  static final TextStyle tabTitle = _style(36, 34, weight: FontWeight.w800, letterSpacing: _em(36, -0.04));
  static final TextStyle briefQuestion = _style(34, 34, weight: FontWeight.w900, letterSpacing: _em(34, -0.04));
  static final TextStyle briefSummaryTitle = _style(32, 33, weight: FontWeight.w900, letterSpacing: _em(32, -0.04));
  static final TextStyle readerTitle = _style(32, 33, weight: FontWeight.w800, letterSpacing: _em(32, -0.035));
  static final TextStyle headline = _style(31, 32, weight: FontWeight.w800, letterSpacing: _em(31, -0.035));
  static final TextStyle briefCardHeadline = _style(28, 30, weight: FontWeight.w800, letterSpacing: _em(28, -0.03));
  static final TextStyle title = _style(22, 24, weight: FontWeight.w800, letterSpacing: _em(22, -0.025));
  static final TextStyle dialogTitle = _style(20, 24, weight: FontWeight.w800, letterSpacing: _em(20, -0.02));
  static final TextStyle cardTitle = _style(18, 20.5, weight: FontWeight.w800, letterSpacing: _em(18, -0.02));
  static final TextStyle counter = _style(34, 31, weight: FontWeight.w900, letterSpacing: _em(34, -0.03));

  // Text and controls.
  static final TextStyle body = _style(16, 26);
  static final TextStyle bodySmall = _style(13, 20);
  static final TextStyle valueLine = _style(15, 22, weight: FontWeight.w600);
  static final TextStyle label = _style(12, 16, weight: FontWeight.w600);
  static final TextStyle button = _style(13, 16, weight: FontWeight.w800, letterSpacing: _em(13, 0.06));
  static final TextStyle buttonSecondary = _style(12, 16, weight: FontWeight.w800, letterSpacing: _em(12, 0.1));
  static final TextStyle caption = _style(11, 16, weight: FontWeight.w600, letterSpacing: _em(11, 0.05));
  static final TextStyle captionSmall = _style(11, 14, weight: FontWeight.w600, letterSpacing: _em(11, 0.04));
  static final TextStyle navLabel = _style(10, 12, weight: FontWeight.w800, letterSpacing: _em(10, 0.1));

  /// Kicker above a headline ("PORTADA · WORLD"): small capitals, wide.
  static final TextStyle overline = _style(10.5, 14, weight: FontWeight.w800, letterSpacing: _em(10.5, 0.14));

  /// Section head in a list ("RECENT", "APPEARANCE").
  static final TextStyle sectionOverline = _style(11, 14, weight: FontWeight.w800, letterSpacing: _em(11, 0.14));

  /// Row numbers and counters ("02", "07"): tabular figures so columns align.
  static TextStyle numeral(double size, {FontWeight weight = FontWeight.w800}) {
    return _style(size, size * 1.1, weight: weight, letterSpacing: _em(size, 0.04))
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  }

  /// Large single glyphs: the mark's fallback letter, empty-state glyph,
  /// avatar initials, plate fallbacks. Sized by the widget, never ad hoc.
  static TextStyle glyph(double size, {FontWeight weight = FontWeight.w800}) =>
      _style(size, size, weight: weight, letterSpacing: _em(size, -0.03));

  /// Text at an explicit size for controls that are not part of the scale
  /// (the A- / A+ stepper, slider ends).
  static TextStyle sized(double size, {FontWeight weight = FontWeight.w400}) =>
      _style(size, size * 1.2, weight: weight);

  /// Material [TextTheme] fed from the same scale so M3 widgets pick it up.
  static TextTheme textTheme(Color ink, Color inkBody, Color inkSecondary) {
    return TextTheme(
      displayLarge: display.copyWith(color: ink),
      displayMedium: tabTitle.copyWith(color: ink),
      displaySmall: readerTitle.copyWith(color: ink),
      headlineLarge: headline.copyWith(color: ink),
      headlineMedium: dialogTitle.copyWith(color: ink),
      headlineSmall: cardTitle.copyWith(color: ink),
      titleLarge: title.copyWith(color: ink),
      titleMedium: valueLine.copyWith(color: ink),
      titleSmall: label.copyWith(color: inkSecondary),
      bodyLarge: body.copyWith(color: inkBody),
      bodyMedium: bodySmall.copyWith(color: inkBody),
      bodySmall: caption.copyWith(color: inkSecondary),
      labelLarge: button.copyWith(color: ink),
      labelMedium: buttonSecondary.copyWith(color: ink),
      labelSmall: overline.copyWith(color: inkSecondary),
    );
  }
}
