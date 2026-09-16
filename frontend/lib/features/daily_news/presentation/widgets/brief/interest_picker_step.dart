import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/brief/brief_cubit.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';

/// Step 1 of 3: pick the topics for today's five stories, as framed blocks
/// that fill with ink when chosen.
class InterestPickerStep extends StatelessWidget {
  final Set<NewsCategory> selected;
  final bool isLoading;
  final ValueChanged<NewsCategory> onToggle;
  final VoidCallback onSurpriseMe;
  final VoidCallback onStart;
  final VoidCallback onClose;

  const InterestPickerStep({
    super.key,
    required this.selected,
    required this.isLoading,
    required this.onToggle,
    required this.onSurpriseMe,
    required this.onStart,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  LabeledIconButton.close(onPressed: onClose),
                  const Spacer(),
                  Text('STEP 1 OF 3', style: AppTypography.sectionOverline.copyWith(color: palette.inkSecondary)),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: AppSpacing.lg),
                  children: [
                    Text(
                      'WHAT DO YOU WANT TO READ TODAY?',
                      style: AppTypography.briefQuestion.copyWith(color: palette.ink),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Pick as many as you like.', style: AppTypography.bodySmall.copyWith(color: palette.inkBody)),
                    const SizedBox(height: AppSpacing.xxl),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final topic in BriefCubit.topics)
                          _InterestChip(
                            label: topic.label,
                            selected: selected.contains(topic),
                            onPressed: () => onToggle(topic),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    OutlinedButton.icon(
                      onPressed: onSurpriseMe,
                      icon: Icon(Icons.auto_awesome_rounded, color: palette.primary, size: 18),
                      label: const Text('Surprise me'),
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                label: selected.isEmpty
                    ? 'Pick a topic to start'
                    : 'Start with ${selected.length} ${selected.length == 1 ? 'topic' : 'topics'}',
                isLoading: isLoading,
                onPressed: selected.isEmpty ? null : onStart,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'FIVE STORIES · ABOUT 4 MINUTES',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: palette.inkSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _InterestChip({required this.label, required this.selected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final duration = AppMotion.durationFor(context, AppMotion.short);
    final foreground = selected ? palette.background : palette.ink;
    return Semantics(
      selected: selected,
      child: AnimatedScale(
        scale: selected ? 1.03 : 1,
        duration: duration,
        curve: Curves.easeOutBack,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOutCubic,
              height: AppSizes.button,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: selected ? palette.ink : Colors.transparent,
                border: Border.all(color: palette.ink, width: AppRules.strong),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: duration,
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      selected ? Icons.check_rounded : Icons.add_rounded,
                      key: ValueKey(selected),
                      size: 18,
                      color: selected ? palette.primary : palette.ink,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedDefaultTextStyle(
                    duration: duration,
                    style: AppTypography.button.copyWith(color: foreground),
                    child: Text(label.toUpperCase()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
