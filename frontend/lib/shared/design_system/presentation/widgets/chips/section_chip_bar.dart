import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/chips/section_chip.dart';

class SectionChipBar<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final ValueChanged<T> onItemChanged;
  final String Function(T item) labelBuilder;

  const SectionChipBar({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemChanged,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing24,
      ),
      child: Row(
        children: items.map((item) {
          final isLast = item == items.last;
          return Padding(
            padding: EdgeInsets.only(
              right: isLast ? 0 : AppDimensions.spacing8,
            ),
            child: SectionChip(
              label: labelBuilder(item),
              isActive: item == selectedItem,
              onTap: () => onItemChanged(item),
            ),
          );
        }).toList(),
      ),
    );
  }
}
