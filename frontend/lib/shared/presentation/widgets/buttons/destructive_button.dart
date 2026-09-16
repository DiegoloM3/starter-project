import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Buttons for irreversible actions, always in the error colour.
class DestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  /// Filled (dialog confirmation) or outlined (in-page trigger).
  final bool filled;
  final IconData? icon;

  const DestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final error = context.palette.error;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppSizes.buttonIcon),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );

    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: error,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSizes.button),
          textStyle: AppTypography.button,
        ),
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: error,
        side: BorderSide(color: error, width: 2),
        minimumSize: const Size.fromHeight(AppSizes.tertiaryButton),
        textStyle: AppTypography.buttonSecondary,
      ),
      child: child,
    );
  }
}
