import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/theme.dart';

/// Consistent snackbar utility for success, error and info feedback.
abstract final class AppSnackbar {
  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.accent, Icons.check_circle_outline, Colors.black);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.error, Icons.error_outline, Colors.white);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppColors.info, Icons.info_outline, Colors.white);

  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
    Color foreground,
  ) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: foreground, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: foreground, fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          margin: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.xl,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
