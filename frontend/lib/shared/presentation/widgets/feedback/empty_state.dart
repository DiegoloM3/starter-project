import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Empty state, set like a short column of newsprint: a rule, one big red
/// glyph or icon, a plain-words headline, one sentence and one call to action,
/// all left-aligned.
class EmptyState extends StatelessWidget {
  final String title;
  final String message;

  /// A single character shown large ("n", "?", "¶").
  final String? glyph;

  /// Used instead of [glyph].
  final IconData? icon;
  final Widget? action;

  /// Rich body replacing [message] when the copy needs inline widgets.
  final Widget? messageWidget;

  const EmptyState({
    super.key,
    required this.title,
    this.message = '',
    this.glyph,
    this.icon,
    this.action,
    this.messageWidget,
  }) : assert(glyph != null || icon != null, 'Provide a glyph or an icon');

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.huge, AppSpacing.screenMargin, AppSpacing.huge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: palette.outline, thickness: AppRules.strong, height: AppRules.strong),
          const SizedBox(height: AppSpacing.xl),
          if (icon != null)
            Icon(icon, size: 40, color: palette.primary)
          else
            Text(
              glyph!,
              style: AppTypography.glyph(56, weight: FontWeight.w900).copyWith(color: palette.primary),
            ),
          const SizedBox(height: AppSpacing.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Text(title, style: AppTypography.title.copyWith(color: palette.ink)),
          ),
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: messageWidget ??
                Text(message, style: AppTypography.bodySmall.copyWith(color: palette.inkSecondary)),
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.xxl),
            action!,
          ],
        ],
      ),
    );
  }
}
