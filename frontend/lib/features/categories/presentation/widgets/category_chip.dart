import 'package:flutter/material.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';

class CategoryChip extends StatelessWidget {
  final CategoryEntity category;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(category.name),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
