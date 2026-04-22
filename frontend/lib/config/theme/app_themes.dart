import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

ThemeData theme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    fontFamily: 'Muli',
    appBarTheme: appBarTheme(),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textHeadline, fontWeight: FontWeight.bold, fontSize: 32),
      headlineMedium: TextStyle(color: AppColors.textHeadline, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: AppColors.textHeadline, fontWeight: FontWeight.w600, fontSize: 18),
      bodyLarge: TextStyle(color: AppColors.textBody, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textBody, fontSize: 14),
      labelMedium: TextStyle(color: AppColors.textMuted, fontSize: 12),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.primary),
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.highlight,
      onPrimary: Colors.black,
      onSurface: Colors.white,
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.black,
    ),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white, 
      fontSize: 22, 
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5
    ),
  );
}