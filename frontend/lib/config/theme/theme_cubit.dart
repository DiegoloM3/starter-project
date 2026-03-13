import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/secure_storage_service.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';
  final SecureStorageService _storageService;

  ThemeCubit({required SecureStorageService storageService})
      : _storageService = storageService,
        super(ThemeState.initial());

  /// Initialize theme from saved preferences
  Future<void> init() async {
    final savedTheme = await _storageService.read(_themeKey);

    if (savedTheme != null) {
      final themeMode = AppThemeMode.values.firstWhere(
        (e) => e.name == savedTheme,
        orElse: () => AppThemeMode.light,
      );
      _applyTheme(themeMode);
    } else {
      // Default to light mode
      _applyTheme(AppThemeMode.light);
    }
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    final newMode = state.isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    setTheme(newMode);
  }

  /// Set specific theme mode
  Future<void> setTheme(AppThemeMode mode) async {
    _applyTheme(mode);

    // Save preference
    await _storageService.write(_themeKey, mode.name);
  }

  void _applyTheme(AppThemeMode mode) {
    ThemeMode materialMode;

    switch (mode) {
      case AppThemeMode.light:
        materialMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        materialMode = ThemeMode.dark;
        break;
      case AppThemeMode.system:
        // Get system brightness
        final brightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        materialMode =
            brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
        break;
    }

    emit(ThemeState(
      themeMode: mode,
      materialThemeMode: materialMode,
    ));
  }
}
