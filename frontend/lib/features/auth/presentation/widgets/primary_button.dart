import 'package:flutter/material.dart';

import '../../../../config/theme/app_themes.dart';

/// Full-width vermilion CTA button shared across the auth pages.
class PrimaryButton extends StatelessWidget {
  final String label;
  final String loadingLabel;
  final bool isLoading;
  final VoidCallback onPressed;

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.loadingLabel,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? const Color(0xFF991818) : cs.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF991818),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.88),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: isLoading ? 0 : 4,
          shadowColor: cs.primary.withValues(alpha: 0.21),
        ),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    loadingLabel,
                    style: tt.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                style: tt.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
