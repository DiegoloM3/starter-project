import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;

  /// Override the default full-width behaviour. Pass a finite value to
  /// constrain width; leave null for full-width.
  final double? width;

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isDisabled ? 0.5 : 1.0,
      child: SizedBox(
        width: width ?? double.infinity,
        height: AppMetrics.h(52),
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppMetrics.r(12)),
            ),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            elevation: 0,
          ),
          child: _child(Colors.white),
        );

      case AppButtonVariant.secondary:
        return OutlinedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            side: BorderSide(
              color: _isDisabled ? AppColors.border : AppColors.accent,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppMetrics.r(12)),
            ),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          child: _child(AppColors.accent),
        );

      case AppButtonVariant.text:
        return TextButton(
          onPressed: _isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          child: _child(AppColors.accent),
        );
    }
  }

  Widget _child(Color spinnerColor) {
    if (isLoading) {
      return SizedBox(
        width: AppMetrics.r(20),
        height: AppMetrics.r(20),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
        ),
      );
    }
    return Text(label, style: AppTypography.labelLarge);
  }
}
