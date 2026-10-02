import 'package:flutter/material.dart';

/// Colors of the app design. Each theme has its own palette, so widgets ask the current theme
/// for a color (`context.palette.primary`) instead of using a fixed one.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  static const AppPalette light = AppPalette(
    background: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF1E6FD9),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE3EFFC),
    textPrimary: Color(0xFF15181E),
    textSecondary: Color(0xFF5A6472),
    icon: Color(0xFF6B7686),
    divider: Color(0xFFE1E6ED),
    inputBorder: Color(0xFFD3DBE5),
    dashedBorder: Color(0xFFA9BDD6),
    imagePlaceholder: Color(0xFFE4EAF2),
    navigationBar: Color(0xD1EBF2FB),
    navigationBorder: Color(0x1A1E6FD9),
    navigationShadow: Color(0x1F15181E),
    skeletonBase: Color(0xFFE4EAF2),
    skeletonHighlight: Color(0xFFF5F8FC),
    error: Color(0xFFB3261E),
    errorSoft: Color(0xFFFBE9E8),
    success: Color(0xFF1F8A5B),
    successSoft: Color(0xFFE3F4EC),
  );

  static const AppPalette dark = AppPalette(
    background: Color(0xFF101418),
    surface: Color(0xFF1A1F26),
    primary: Color(0xFF6AA8F7),
    onPrimary: Color(0xFF0B1A2E),
    primarySoft: Color(0xFF1C2C44),
    textPrimary: Color(0xFFE8ECF2),
    textSecondary: Color(0xFFA3ADBB),
    icon: Color(0xFF8C97A6),
    divider: Color(0xFF252B34),
    inputBorder: Color(0xFF2E3640),
    dashedBorder: Color(0xFF3E5470),
    imagePlaceholder: Color(0xFF1F2630),
    navigationBar: Color(0xD11C232E),
    navigationBorder: Color(0x246AA8F7),
    navigationShadow: Color(0x73000000),
    skeletonBase: Color(0xFF1F2630),
    skeletonHighlight: Color(0xFF2C3542),
    error: Color(0xFFF2B8B5),
    errorSoft: Color(0xFF3A2224),
    success: Color(0xFF5CC98E),
    successSoft: Color(0xFF18322A),
  );

  final Color background;
  final Color surface;
  final Color primary;
  final Color onPrimary;
  final Color primarySoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color icon;
  final Color divider;
  final Color inputBorder;
  final Color dashedBorder;
  final Color imagePlaceholder;
  final Color navigationBar;
  final Color navigationBorder;
  final Color navigationShadow;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color error;
  final Color errorSoft;
  final Color success;
  final Color successSoft;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.icon,
    required this.divider,
    required this.inputBorder,
    required this.dashedBorder,
    required this.imagePlaceholder,
    required this.navigationBar,
    required this.navigationBorder,
    required this.navigationShadow,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.error,
    required this.errorSoft,
    required this.success,
    required this.successSoft,
  });

  @override
  AppPalette copyWith() => this;

  /// Blends both palettes while the app animates from one theme to the other.
  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color blend(Color from, Color to) => Color.lerp(from, to, t)!;
    return AppPalette(
      background: blend(background, other.background),
      surface: blend(surface, other.surface),
      primary: blend(primary, other.primary),
      onPrimary: blend(onPrimary, other.onPrimary),
      primarySoft: blend(primarySoft, other.primarySoft),
      textPrimary: blend(textPrimary, other.textPrimary),
      textSecondary: blend(textSecondary, other.textSecondary),
      icon: blend(icon, other.icon),
      divider: blend(divider, other.divider),
      inputBorder: blend(inputBorder, other.inputBorder),
      dashedBorder: blend(dashedBorder, other.dashedBorder),
      imagePlaceholder: blend(imagePlaceholder, other.imagePlaceholder),
      navigationBar: blend(navigationBar, other.navigationBar),
      navigationBorder: blend(navigationBorder, other.navigationBorder),
      navigationShadow: blend(navigationShadow, other.navigationShadow),
      skeletonBase: blend(skeletonBase, other.skeletonBase),
      skeletonHighlight: blend(skeletonHighlight, other.skeletonHighlight),
      error: blend(error, other.error),
      errorSoft: blend(errorSoft, other.errorSoft),
      success: blend(success, other.success),
      successSoft: blend(successSoft, other.successSoft),
    );
  }
}

extension AppPaletteOfContext on BuildContext {
  /// Palette of the current theme (the light one when the theme has none, e.g. in tests).
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

ThemeData lightTheme() => _buildTheme(AppPalette.light, Brightness.light);

ThemeData darkTheme() => _buildTheme(AppPalette.dark, Brightness.dark);

ThemeData _buildTheme(AppPalette palette, Brightness brightness) {
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: palette.background,
    fontFamily: 'Muli',
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      surface: palette.background,
      onSurface: palette.textPrimary,
      error: palette.error,
    ),
    dividerColor: palette.divider,
    extensions: [palette],
    appBarTheme: _appBarTheme(palette),
    tabBarTheme: _tabBarTheme(palette),
    inputDecorationTheme: _inputDecorationTheme(palette),
    filledButtonTheme: _filledButtonTheme(palette),
    outlinedButtonTheme: _outlinedButtonTheme(palette),
  );
}

AppBarTheme _appBarTheme(AppPalette palette) {
  return AppBarTheme(
    backgroundColor: palette.background,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: palette.textPrimary),
    titleTextStyle: TextStyle(
      fontFamily: 'Muli',
      color: palette.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w800,
    ),
  );
}

TabBarThemeData _tabBarTheme(AppPalette palette) {
  return TabBarThemeData(
    labelColor: palette.primary,
    unselectedLabelColor: palette.textSecondary,
    indicatorColor: palette.primary,
    indicatorSize: TabBarIndicatorSize.tab,
    dividerColor: palette.divider,
    labelStyle: const TextStyle(fontFamily: 'Muli', fontSize: 14, fontWeight: FontWeight.w800),
    unselectedLabelStyle: const TextStyle(fontFamily: 'Muli', fontSize: 14, fontWeight: FontWeight.w600),
  );
}

InputDecorationTheme _inputDecorationTheme(AppPalette palette) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );
  return InputDecorationTheme(
    filled: true,
    fillColor: palette.surface,
    hintStyle: TextStyle(color: palette.textSecondary),
    helperStyle: TextStyle(fontSize: 12, color: palette.textSecondary),
    helperMaxLines: 2,
    errorMaxLines: 2,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: border(palette.inputBorder),
    enabledBorder: border(palette.inputBorder),
    disabledBorder: border(palette.inputBorder),
    focusedBorder: border(palette.primary),
    errorBorder: border(palette.error),
    focusedErrorBorder: border(palette.error),
  );
}

FilledButtonThemeData _filledButtonTheme(AppPalette palette) {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: palette.primary,
      foregroundColor: palette.onPrimary,
      minimumSize: const Size.fromHeight(56),
      shape: const StadiumBorder(),
      textStyle: const TextStyle(fontFamily: 'Muli', fontSize: 16, fontWeight: FontWeight.w800),
    ),
  );
}

OutlinedButtonThemeData _outlinedButtonTheme(AppPalette palette) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: palette.surface,
      foregroundColor: palette.primary,
      minimumSize: const Size.fromHeight(56),
      shape: const StadiumBorder(),
      side: BorderSide(color: palette.inputBorder, width: 1.5),
      textStyle: const TextStyle(fontFamily: 'Muli', fontSize: 16, fontWeight: FontWeight.w800),
    ),
  );
}
