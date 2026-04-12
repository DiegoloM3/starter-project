import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/chips/section_chip.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/ui_elements/form_field_label.dart';

class FormSectionSelector<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T> onChanged;
  final String Function(T item) labelBuilder;

  const FormSectionSelector({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FormFieldLabel(label: label),
        const SizedBox(height: AppDimensions.spacing10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
                  onTap: () => onChanged(item),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
