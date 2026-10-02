import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';

extension AppThemeMode on AppTheme {
  /// How Flutter shows each theme: `system` follows the phone's setting.
  ThemeMode get themeMode {
    switch (this) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }
}
