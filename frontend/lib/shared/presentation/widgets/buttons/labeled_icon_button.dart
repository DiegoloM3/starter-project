import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Icon plus a visible word in small capitals, 48dp tall: "← BACK",
/// "× CLOSE". The design never uses a bare icon for navigation, so the label
/// is required. With a [backgroundColor] it becomes a framed block (the
/// glass button over a photo).
class LabeledIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  /// Overrides the ink foreground, e.g. paper on dark plates.
  final Color? color;

  /// Fill behind the button; also draws the 2px frame around it.
  final Color? backgroundColor;

  const LabeledIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.backgroundColor,
  });

  const LabeledIconButton.back({super.key, required this.onPressed, this.color, this.backgroundColor})
      : icon = Icons.arrow_back_rounded,
        label = 'Back';

  const LabeledIconButton.close({super.key, required this.onPressed, this.color, this.backgroundColor})
      : icon = Icons.close_rounded,
        label = 'Close';

  const LabeledIconButton.cancel({super.key, required this.onPressed, this.color, this.backgroundColor})
      : icon = Icons.close_rounded,
        label = 'Cancel';

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = color ?? palette.ink;
    final framed = backgroundColor != null;
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: backgroundColor,
        minimumSize: const Size(AppSizes.touchTarget, AppSizes.touchTarget),
        padding: EdgeInsets.symmetric(horizontal: framed ? AppSpacing.md : AppSpacing.sm),
        shape: RoundedRectangleBorder(
          side: framed ? BorderSide(color: foreground, width: AppRules.strong) : BorderSide.none,
        ),
        textStyle: AppTypography.buttonSecondary,
      ),
      icon: Icon(icon, size: AppSizes.buttonIcon),
      label: Text(label.toUpperCase()),
    );
  }
}
