import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

class ThemeState extends Equatable {
  final AppThemeMode themeMode;
  final ThemeMode materialThemeMode;

  const ThemeState({
    required this.themeMode,
    required this.materialThemeMode,
  });

  factory ThemeState.initial() {
    return const ThemeState(
      themeMode: AppThemeMode.light,
      materialThemeMode: ThemeMode.light,
    );
  }

  bool get isDarkMode => materialThemeMode == ThemeMode.dark;

  ThemeState copyWith({
    AppThemeMode? themeMode,
    ThemeMode? materialThemeMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      materialThemeMode: materialThemeMode ?? this.materialThemeMode,
    );
  }

  @override
  List<Object?> get props => [themeMode, materialThemeMode];
}
