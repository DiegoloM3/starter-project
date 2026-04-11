import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

final ThemeData lightThemeData =
    _buildTheme(Brightness.light, AppColorsExtension.light);
final ThemeData darkThemeData =
    _buildTheme(Brightness.dark, AppColorsExtension.dark);

ThemeData _buildTheme(Brightness brightness, AppColorsExtension colors) {
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: colors.bgPage,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accentGreen,
      brightness: brightness,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.bgCard,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: colors.textPrimary),
      titleTextStyle:
          AppTypography.buttonLarge.copyWith(color: colors.textPrimary),
    ),
    extensions: [colors],
  );
}
