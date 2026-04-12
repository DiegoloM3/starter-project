import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_tokens.dart';

/// Centralised Material 3 themes for the app.
///
/// The light theme is the original "Daily News" look (white scaffold,
/// grey app bar text, Muli body font). The dark theme is a new addition
/// delivered as part of Phase 5 overdelivery — it honours `ThemeMode.system`
/// so users on Android 10+ get dark mode automatically when the system
/// preference is set.
///
/// Both themes expose a consistent `ColorScheme` so widgets can read
/// `Theme.of(context).colorScheme.onSurface` instead of hard-coding
/// `Colors.black`. This is how we avoid "light theme bleeding through"
/// on dark backgrounds.

const _brandSeed = Color(0xFFE8D44D);

ThemeData lightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _brandSeed,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Muli',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0XFF8B8B8B)),
      titleTextStyle: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
    ),
    extensions: const <ThemeExtension>[AppTokens.light],
  );
}

ThemeData darkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _brandSeed,
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFF3D3D3D),
    fontFamily: 'Muli',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2D2D2D),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFFE0E0E0)),
      titleTextStyle: TextStyle(
        color: Color(0xFFE0E0E0),
        fontSize: 18,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF2D2D2D),
      elevation: 1,
      margin: EdgeInsets.zero,
    ),
    extensions: const <ThemeExtension>[AppTokens.dark],
  );
}

/// Backwards-compatible alias so any pre-existing call site still compiles.
@Deprecated('Use lightTheme() directly. Kept for transitional compatibility.')
ThemeData theme() => lightTheme();
