import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// One-of chips for the article's category. The selected chip is never
/// colour-only: it also gets the check mark and bold weight.
class CategoryChips extends StatelessWidget {
  final NewsCategory selected;
  final ValueChanged<NewsCategory> onChanged;

  const CategoryChips({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTypography.label.copyWith(color: palette.ink)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final category in NewsCategory.values)
              ChoiceChip(
                label: Text(
                  category.label,
                  style: TextStyle(
                    fontWeight: category == selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                selected: category == selected,
                onSelected: (_) => onChanged(category),
              ),
          ],
        ),
      ],
    );
  }
}
