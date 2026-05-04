import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';

class CategoryChips extends StatelessWidget {
  final ArticleCategory? selected;
  final ValueChanged<ArticleCategory> onSelected;

  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ArticleCategory.values.map((category) {
        final isSelected = category == selected;
        return ChoiceChip(
          label: Text(category.toApiValue().toUpperCase()),
          selected: isSelected,
          onSelected: (_) => onSelected(category),
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : null,
          ),
        );
      }).toList(),
    );
  }
}
