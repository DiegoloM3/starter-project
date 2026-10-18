import 'package:flutter/material.dart';

/// Black and white editorial style: dark text and lines on white.
/// The dark theme inverts it. Soft tones instead of pure black and white are easier on the eyes.
const Color _softBlack = Color(0xFF2B2B2B);
const Color _darkBackground = Color(0xFF121212);
const Color _softWhite = Color(0xFFEDEDED);

ThemeData lightTheme() => _buildTheme(ink: _softBlack, paper: Colors.white, brightness: Brightness.light);

ThemeData darkTheme() => _buildTheme(ink: _softWhite, paper: _darkBackground, brightness: Brightness.dark);

const BorderRadius _squareCorners = BorderRadius.zero;

ThemeData _buildTheme({required Color ink, required Color paper, required Brightness brightness}) {
  final colorScheme = _colorScheme(ink: ink, paper: paper, brightness: brightness);
  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: paper,
    fontFamily: 'Muli',
    splashFactory: NoSplash.splashFactory,
    appBarTheme: _appBarTheme(ink: ink, paper: paper),
    navigationBarTheme: _navigationBarTheme(ink: ink, paper: paper),
    dividerTheme: DividerThemeData(color: ink, thickness: 1, space: 1),
    inputDecorationTheme: _inputDecorationTheme(ink: ink, error: colorScheme.error),
    filledButtonTheme: FilledButtonThemeData(style: _filledButtonStyle(ink: ink, paper: paper)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _outlinedButtonStyle(ink: ink)),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: ink)),
    chipTheme: _chipTheme(ink: ink, paper: paper),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      contentTextStyle: TextStyle(color: paper, fontFamily: 'Muli'),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: _squareCorners),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: paper,
      shape: RoundedRectangleBorder(borderRadius: _squareCorners, side: BorderSide(color: ink)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: paper,
      shape: RoundedRectangleBorder(borderRadius: _squareCorners, side: BorderSide(color: ink)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: ink),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: ink,
      selectionColor: ink.withValues(alpha: 0.2),
      selectionHandleColor: ink,
    ),
  );
}

ColorScheme _colorScheme({required Color ink, required Color paper, required Brightness brightness}) {
  final greyText = ink.withValues(alpha: 0.6);
  return ColorScheme(
    brightness: brightness,
    primary: ink,
    onPrimary: paper,
    secondary: ink,
    onSecondary: paper,
    surface: paper,
    onSurface: ink,
    onSurfaceVariant: greyText,
    surfaceContainerHighest: ink.withValues(alpha: 0.06),
    outline: ink,
    outlineVariant: ink.withValues(alpha: 0.2),
    error: brightness == Brightness.light ? const Color(0xFFB00020) : const Color(0xFFFF6E6E),
    onError: paper,
  );
}

AppBarTheme _appBarTheme({required Color ink, required Color paper}) {
  return AppBarTheme(
    backgroundColor: paper,
    foregroundColor: ink,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    shape: Border(bottom: BorderSide(color: ink)),
    titleTextStyle: TextStyle(color: ink, fontFamily: 'Muli', fontSize: 20, fontWeight: FontWeight.w700),
  );
}

NavigationBarThemeData _navigationBarTheme({required Color ink, required Color paper}) {
  return NavigationBarThemeData(
    backgroundColor: paper,
    surfaceTintColor: Colors.transparent,
    indicatorColor: Colors.transparent,
    height: 64,
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(color: states.contains(WidgetState.selected) ? ink : ink.withValues(alpha: 0.45)),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        fontSize: 11,
        color: states.contains(WidgetState.selected) ? ink : ink.withValues(alpha: 0.45),
        fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w400,
      ),
    ),
  );
}

InputDecorationTheme _inputDecorationTheme({required Color ink, required Color error}) {
  OutlineInputBorder border(Color color, double width) {
    return OutlineInputBorder(borderRadius: _squareCorners, borderSide: BorderSide(color: color, width: width));
  }

  return InputDecorationTheme(
    border: border(ink, 1),
    enabledBorder: border(ink, 1),
    focusedBorder: border(ink, 2),
    errorBorder: border(error, 1),
    focusedErrorBorder: border(error, 2),
    labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
    floatingLabelStyle: TextStyle(color: ink),
  );
}

ButtonStyle _filledButtonStyle({required Color ink, required Color paper}) {
  return FilledButton.styleFrom(
    backgroundColor: ink,
    foregroundColor: paper,
    minimumSize: const Size.fromHeight(52),
    shape: const RoundedRectangleBorder(borderRadius: _squareCorners),
    textStyle: const TextStyle(fontFamily: 'Muli', fontWeight: FontWeight.w700, letterSpacing: 1),
  );
}

ButtonStyle _outlinedButtonStyle({required Color ink}) {
  return OutlinedButton.styleFrom(
    foregroundColor: ink,
    side: BorderSide(color: ink),
    shape: const RoundedRectangleBorder(borderRadius: _squareCorners),
  );
}

ChipThemeData _chipTheme({required Color ink, required Color paper}) {
  return ChipThemeData(
    backgroundColor: paper,
    selectedColor: ink,
    disabledColor: paper,
    checkmarkColor: paper,
    side: BorderSide(color: ink),
    shape: const RoundedRectangleBorder(borderRadius: _squareCorners),
    labelStyle: TextStyle(color: ink, fontFamily: 'Muli'),
    secondaryLabelStyle: TextStyle(color: paper, fontFamily: 'Muli'),
  );
}
