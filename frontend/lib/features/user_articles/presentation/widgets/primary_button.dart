import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme_extension.dart';

/// Filled call-to-action button consistent across user_articles screens.
///
/// Uses `AppTheme.primary` / `onPrimary` so a single token swap repaints
/// every CTA in the app.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final enabled = onPressed != null && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primary,
          foregroundColor: theme.onPrimary,
          disabledBackgroundColor: theme.primary.withOpacity(0.4),
          disabledForegroundColor: theme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: theme.radii.mdRadius,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.onPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    SizedBox(width: theme.spacing.sm),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
