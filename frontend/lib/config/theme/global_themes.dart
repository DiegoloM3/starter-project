import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalTheme {
  // paleta
  static const Color kPaper = Color(0xFFF7F4EC);       // papel, el 60%
  static const Color kInk = Color(0xFF201D1A);          // tinta, negro cálido
  static const Color kInkMuted = Color(0xFF6B655C);     // tinta diluida, texto secundario
  static const Color kRule = Color(0xFFD8D2C4);         // línea divisoria
  static const Color kOxblood = Color(0xFF7A2E2E);      // el único acento, serio

  static const Color kInkDarkBg = Color(0xFF17140F);
  static const Color kPaperDark = Color(0xFFEDE7DA);
  static const Color kOxbloodDark = Color(0xFFA34444);  // un poco más claro, para contraste en dark

  static final Color _lightFocusColor = Colors.black.withValues(alpha: 0.12);
  static final Color _darkFocusColor = Colors.white.withValues(alpha: 0.12);

  static final ColorScheme _lightColorScheme = ColorScheme(
    primary: kInk,
    onPrimary: kPaper,
    secondary: kOxblood,
    onSecondary: kPaper,
    tertiary: kRule,
    onTertiary: kInk,
    primaryContainer: kRule,
    secondaryContainer: kOxblood,
    tertiaryContainer: kPaper,
    error: const Color(0xFF7A2E2E),
    onError: kPaper,
    surface: kPaper,
    onSurface: kInk,
    brightness: Brightness.light,
  );

  static final ColorScheme _darkColorScheme = ColorScheme(
    primary: kPaperDark,
    onPrimary: kInkDarkBg,
    secondary: kOxbloodDark,
    onSecondary: kInkDarkBg,
    tertiary: kInkMuted,
    onTertiary: kPaperDark,
    primaryContainer: const Color(0xFF2A251E),
    secondaryContainer: kOxbloodDark,
    tertiaryContainer: const Color(0xFF2A251E),
    error: kOxbloodDark,
    onError: kInkDarkBg,
    surface: kInkDarkBg,
    onSurface: kPaperDark,
    brightness: Brightness.dark,
  );

  static ThemeData lightThemeData = _themeData(_lightColorScheme, _lightFocusColor);
  static ThemeData darkThemeData = _themeData(_darkColorScheme, _darkFocusColor);


  static TextStyle masthead(ColorScheme colorScheme, {double fontSize = 24}) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
      color: colorScheme.primary,
    );
  }

  static ThemeData _themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      colorScheme: colorScheme,
      fontFamily: 'Muli',
      canvasColor: colorScheme.surface,
      scaffoldBackgroundColor: colorScheme.surface,
      highlightColor: Colors.transparent,
      focusColor: focusColor,
      dividerColor: kRule,
      iconTheme: _iconTheme(colorScheme),
      textTheme: _textTheme(colorScheme),
      appBarTheme: _appBarTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      floatingActionButtonTheme: _floatingActionButtonTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(),
    );
  }

  static AppBarTheme _appBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: colorScheme.primary),
    );
  }

  static FloatingActionButtonThemeData _floatingActionButtonTheme(ColorScheme colorScheme) {
  return FloatingActionButtonThemeData(
    backgroundColor: colorScheme.secondary,
    foregroundColor: colorScheme.onSecondary,
    elevation: 0,                   
    extendedTextStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,  
    ),
  );
}

  static TextButtonThemeData _textButtonTheme(ColorScheme colorScheme) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: colorScheme.secondary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),   
    ),
  );
}


static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: colorScheme.onSecondary,
      backgroundColor: colorScheme.secondary,
      disabledBackgroundColor: colorScheme.secondary,
      disabledForegroundColor: colorScheme.onSecondary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      fixedSize: const Size.fromHeight(52),
    ),
  );
}

  static IconThemeData _iconTheme(ColorScheme colorScheme) {
    return IconThemeData(color: colorScheme.primary, size: 23);
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    return TextTheme(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      bodyLarge: TextStyle(fontSize: 17, height: 1.5, color: colorScheme.onSurface),
      bodyMedium: TextStyle(fontSize: 15, height: 1.4, color: colorScheme.onSurface),
      bodySmall: TextStyle(fontSize: 13, color: colorScheme.tertiary == colorScheme.onSurface ? colorScheme.onSurface.withValues(alpha: 0.6) : colorScheme.onSurface.withValues(alpha: 0.6)),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colorScheme.onSecondary),
    );
  }

  static InputDecorationTheme _inputDecorationTheme() {
  return const InputDecorationTheme(
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    isDense: true,
  );
}

  
}