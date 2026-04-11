import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

Widget testableWidget(Widget child) {
  return MaterialApp(
    theme: lightThemeData,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

const AppColorsExtension testColors = AppColorsExtension.light;
