import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

/// Maps the framework-free [AppThemeMode] onto Flutter's [ThemeMode].
extension AppThemeModeMapper on AppThemeMode {
  ThemeMode get material => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}
