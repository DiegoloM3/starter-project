import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const TextStyle headline = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textContent,
    fontSize: 15,
    height: 1.6,
  );

  static const TextStyle input = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
  );

  static const TextStyle inputBody = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 15,
    height: 1.6,
  );

  static const TextStyle label = TextStyle(
    color: AppColors.textMuted,
    fontSize: 13,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.textMuted,
    fontSize: 12,
  );

  static const TextStyle hint = TextStyle(
    color: AppColors.textHint,
    fontSize: 15,
  );

  static const TextStyle hintSmall = TextStyle(
    color: AppColors.textHint,
    fontSize: 13,
  );

  static const TextStyle button = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const TextStyle tag = TextStyle(
    color: AppColors.accent,
    fontSize: 12,
  );

  static const TextStyle preview = TextStyle(
    color: AppColors.accent,
    fontSize: 15,
  );
}
