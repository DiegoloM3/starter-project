import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

import 'news_formatting.dart';

/// The feed's sections, scrolling sideways so they fit any screen width.
class CategoryBar extends StatelessWidget {
  final NewsCategory selected;
  final ValueChanged<NewsCategory> onSelected;

  const CategoryBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: NewsCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = NewsCategory.values[index];
          return Center(
            child: ChoiceChip(
              label: Text(categoryLabel(category, context.l10n)),
              selected: category == selected,
              showCheckmark: false,
              onSelected: (_) => onSelected(category),
            ),
          );
        },
      ),
    );
  }
}
