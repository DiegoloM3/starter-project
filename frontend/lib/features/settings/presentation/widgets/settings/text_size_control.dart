import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

/// "Text size" block: the step's name in figures, a four-step slider between
/// a small and a big "A", and a framed preview paragraph at that size.
class TextSizeControl extends StatelessWidget {
  final TextSizePreference selected;
  final ValueChanged<TextSizePreference> onChanged;

  const TextSizeControl({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const String previewText =
      'The quick brown fox jumps over the lazy dog. Pick the size that reads '
      'best for you.';

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final steps = TextSizePreference.values;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.md, AppSpacing.screenMargin, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text('Text size', style: AppTypography.valueLine.copyWith(color: palette.ink, fontSize: 16)),
              ),
              Text(selected.label, style: AppTypography.captionSmall.copyWith(color: palette.inkSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text('A', style: AppTypography.sized(13, weight: FontWeight.w800).copyWith(color: palette.ink)),
              Expanded(
                child: Slider(
                  value: selected.index.toDouble(),
                  min: 0,
                  max: (steps.length - 1).toDouble(),
                  divisions: steps.length - 1,
                  label: selected.label,
                  semanticFormatterCallback: (value) => steps[value.round()].label,
                  onChanged: (value) => onChanged(steps[value.round()]),
                ),
              ),
              Text('A', style: AppTypography.sized(24, weight: FontWeight.w800).copyWith(color: palette.ink)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: palette.outlineStrong, width: AppRules.strong)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PREVIEW', style: AppTypography.overline.copyWith(color: palette.inkSecondary)),
                const SizedBox(height: AppSpacing.sm),
                Text(previewText, style: AppTypography.body.copyWith(color: palette.inkBody, fontSize: 15, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
