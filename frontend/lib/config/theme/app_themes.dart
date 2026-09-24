import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Light and dark themes built from [AppColors] and the type scale of
/// `docs/FRONTEND_DESIGN.md`.
///
/// The pairing is deliberate: a serif (Instrument Serif) carries headlines so
/// the app reads like a publication, and a sans (Inter) carries everything the
/// reader has to operate, where legibility beats character.
ThemeData theme() => _themeFor(Brightness.light);

ThemeData darkTheme() => _themeFor(Brightness.dark);

ThemeData _themeFor(Brightness brightness) {
  final isLight = brightness == Brightness.light;

  final background =
      isLight ? AppColors.lightBackground : AppColors.darkBackground;
  final surface = isLight ? AppColors.lightSurface : AppColors.darkSurface;
  final divider = isLight ? AppColors.lightDivider : AppColors.darkDivider;
  final text = isLight ? AppColors.lightText : AppColors.darkText;
  final textMuted =
      isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: brightness,
  ).copyWith(
    primary: AppColors.accent,
    surface: surface,
    error: AppColors.danger,
    onSurface: text,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    dividerColor: divider,
    textTheme: _textTheme(text, textMuted),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: text),
      titleTextStyle: _serif(
        fontSize: 26,
        fontWeight: FontWeight.w400,
        color: text,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        // 48dp tall and generously padded: the smallest target the design is
        // allowed to offer, so the app stays usable for less steady hands.
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        shape: const StadiumBorder(),
        textStyle: _inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        shape: const StadiumBorder(),
        textStyle: _inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        backgroundColor: surface,
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: divider),
        shape: const StadiumBorder(),
        textStyle: _inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        minimumSize: const Size(48, 48),
        textStyle: _inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      labelStyle: _inter(fontSize: 15, color: textMuted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: Colors.transparent,
      elevation: 0,
      height: 72,
      // Labels always visible: an unlabelled icon row is the fastest way to
      // make an app unusable for somebody who does not already know it.
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => _inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: states.contains(WidgetState.selected)
              ? AppColors.accent
              : textMuted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.accent
              : textMuted,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isLight ? AppColors.lightText : AppColors.darkSurface,
      contentTextStyle: _inter(fontSize: 15, color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sheet),
      ),
      // Both styles are set on purpose. Material's default dialog title is
      // `headlineSmall`, which in this type scale is the serif used for
      // headlines — so a dialog came out with a serif question above sans
      // serif text. A dialog is interface, not editorial, and reads as one
      // voice only when the whole of it is Inter.
      titleTextStyle: _inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      contentTextStyle: _inter(
        fontSize: 15,
        color: textMuted,
        height: 1.5,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      side: BorderSide(color: divider),
      labelStyle: _inter(fontSize: 13, fontWeight: FontWeight.w600),
      shape: const StadiumBorder(),
    ),
  );
}

/// Inter, bundled as a variable font.
///
/// The weight is applied twice on purpose. `fontVariations` is what actually
/// moves the font's `wght` axis, which is the only thing a variable font
/// responds to; `fontWeight` is kept alongside it so the rest of the
/// framework still knows how bold the text is meant to be.
TextStyle _inter({
  required double fontSize,
  FontWeight fontWeight = FontWeight.w400,
  Color? color,
  double? height,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontVariations: [
      FontVariation('wght', _axisValueOf(fontWeight)),
    ],
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

/// Instrument Serif, which ships in a single weight — there is no axis to
/// set, so the weight is only carried for the framework's benefit.
TextStyle _serif({
  required double fontSize,
  FontWeight fontWeight = FontWeight.w400,
  Color? color,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'InstrumentSerif',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
  );
}

/// The `wght` axis value a variable font expects, which is exactly what
/// [FontWeight.value] already is (400 for regular, 600 for semibold).
double _axisValueOf(FontWeight weight) => weight.value.toDouble();

/// The type scale of `docs/FRONTEND_DESIGN.md`.
TextTheme _textTheme(Color text, Color textMuted) {
  return TextTheme(
    // DISPLAY — Instrument Serif 38
    displayLarge: _serif(
      fontSize: 38,
      fontWeight: FontWeight.w400,
      color: text,
      height: 1.1,
    ),
    // HEADLINE — Instrument Serif 26
    headlineMedium: _serif(
      fontSize: 26,
      fontWeight: FontWeight.w400,
      color: text,
      height: 1.2,
    ),
    // HEADLINE, smaller, for compact cards
    headlineSmall: _serif(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: text,
      height: 1.25,
    ),
    // TITLE — Inter 600 18
    titleMedium: _inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: text,
    ),
    // BODY — Inter 400 15
    bodyMedium: _inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: textMuted,
      height: 1.5,
    ),
    bodyLarge: _inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: text,
      height: 1.6,
    ),
    // LABEL — Inter 600 13
    labelLarge: _inter(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: text,
      letterSpacing: 0.4,
    ),
    // CAPTION — Inter 500 11
    labelSmall: _inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: textMuted,
      letterSpacing: 0.4,
    ),
  );
}
