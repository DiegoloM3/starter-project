import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// The section strip under the masthead: every category as a block between
/// 2px rules, the chosen one printed in red. Choosing one sets the feed's
/// default category, the same setting Settings exposes.
class CategoryStrip extends StatelessWidget {
  final NewsCategory selected;
  final ValueChanged<NewsCategory> onSelected;

  const CategoryStrip({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final rule = BorderSide(color: palette.outlineStrong, width: AppRules.strong);
    return Container(
      decoration: BoxDecoration(border: Border(top: rule, bottom: rule)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final category in NewsCategory.values)
              _Section(
                label: category.label,
                selected: category == selected,
                onTap: () => onSelected(category),
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Section({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? palette.primary : Colors.transparent,
            border: Border(right: BorderSide(color: palette.outlineStrong, width: AppRules.strong)),
          ),
          child: Text(
            label.toUpperCase(),
            style: AppTypography.buttonSecondary.copyWith(
              color: selected ? palette.background : palette.inkSecondary,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              fontVariations: [FontVariation.weight(selected ? 800 : 600)],
            ),
          ),
        ),
      ),
    );
  }
}
