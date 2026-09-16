import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// One choice in an [OptionPickerList].
class PickerOption<T> {
  final T value;
  final String label;

  const PickerOption({required this.value, required this.label});
}

/// Full-screen radio list between rules: one row per option, the current one
/// printed heavy with a red square, 56dp rows so nothing is fiddly to tap.
class OptionPickerList<T> extends StatelessWidget {
  final List<PickerOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  const OptionPickerList({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: palette.outlineStrong, width: AppRules.strong))),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: options.length,
        separatorBuilder: (_, _) => Divider(color: palette.outline),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option.value == selected;
          return Semantics(
            selected: isSelected,
            inMutuallyExclusiveGroup: true,
            child: InkWell(
              onTap: () => onSelected(option.value),
              hoverColor: palette.surface,
              child: Container(
                constraints: const BoxConstraints(minHeight: AppSizes.button),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin, vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Text('${index + 1}'.padLeft(2, '0'),
                        style: AppTypography.numeral(11).copyWith(color: isSelected ? palette.primary : palette.inkSecondary)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        option.label,
                        style: AppTypography.valueLine.copyWith(
                          color: palette.ink,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          fontVariations: [FontVariation.weight(isSelected ? 800 : 500)],
                        ),
                      ),
                    ),
                    if (isSelected) Icon(Icons.check_rounded, color: palette.primary, size: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
