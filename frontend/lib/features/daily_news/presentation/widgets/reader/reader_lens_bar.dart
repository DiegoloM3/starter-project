import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';

/// Two cells between rules under the author block: Brief it · Plain words.
/// The active one is printed in ink; tapping it again returns to the original.
class ReaderLensBar extends StatelessWidget {
  final ArticleLens? active;
  final ArticleLens? loading;
  final ValueChanged<ArticleLens> onToggle;

  const ReaderLensBar({super.key, required this.active, required this.loading, required this.onToggle});

  static IconData iconFor(ArticleLens lens) => switch (lens) {
        ArticleLens.brief => Icons.bolt_rounded,
        ArticleLens.plain => Icons.spa_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final rule = BorderSide(color: palette.outlineStrong, width: AppRules.strong);
    return Container(
      decoration: BoxDecoration(border: Border(top: rule, bottom: rule)),
      child: Row(
        children: [
          for (final (index, lens) in ArticleLens.values.indexed)
            Expanded(
              child: _Cell(
                lens: lens,
                selected: active == lens,
                loading: loading == lens,
                enabled: loading == null,
                divided: index < ArticleLens.values.length - 1,
                onTap: () => onToggle(lens),
              ),
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final ArticleLens lens;
  final bool selected;
  final bool loading;
  final bool enabled;
  final bool divided;
  final VoidCallback onTap;

  const _Cell({
    required this.lens,
    required this.selected,
    required this.loading,
    required this.enabled,
    required this.divided,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = selected ? palette.background : palette.ink;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? palette.ink : Colors.transparent,
            border: divided ? Border(right: BorderSide(color: palette.outlineStrong, width: AppRules.strong)) : null,
          ),
          child: Row(
            children: [
              if (loading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
                )
              else
                Icon(ReaderLensBar.iconFor(lens), size: 16, color: foreground),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  lens.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.button.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
