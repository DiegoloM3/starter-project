import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// 60dp row: label on the left, current value in figures and a chevron on
/// the right. Tapping opens the picker for that setting.
class SettingsRow extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      hoverColor: palette.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.settingsRow),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: palette.ink, size: 20),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.valueLine.copyWith(color: palette.ink, fontSize: 16),
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: AppTypography.captionSmall.copyWith(color: palette.inkSecondary, fontSize: 12),
                ),
              if (onTap != null) ...[
                const SizedBox(width: AppSpacing.md),
                Icon(Icons.chevron_right_rounded, color: palette.inkSecondary, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
