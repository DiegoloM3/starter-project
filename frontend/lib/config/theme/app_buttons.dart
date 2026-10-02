import 'package:flutter/material.dart';

import 'app_themes.dart';

/// Main action of a screen: a filled pill with a soft shadow in the primary color.
/// While [isLoading], it shows a spinner and cannot be pressed.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _buildButton(palette),
    );
  }

  Widget _buildButton(AppPalette palette) {
    final onPressed = isLoading ? null : this.onPressed;
    final leading = isLoading ? _buildSpinner(palette) : (icon == null ? null : Icon(icon));
    if (leading == null) return FilledButton(onPressed: onPressed, child: Text(label));
    return FilledButton.icon(onPressed: onPressed, icon: leading, label: Text(label));
  }

  Widget _buildSpinner(AppPalette palette) {
    return SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: palette.onPrimary),
    );
  }
}
