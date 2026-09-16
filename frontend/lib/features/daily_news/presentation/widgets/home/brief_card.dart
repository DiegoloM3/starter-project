import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// The ink block at the top of Home that opens Today's Brief: a red kicker,
/// the headline in paper, a count set large on the right. Once the brief was
/// read today it invites to the summary instead.
class BriefCard extends StatelessWidget {
  final bool completedToday;
  final int storyCount;
  final VoidCallback onPressed;

  const BriefCard({
    super.key,
    required this.completedToday,
    required this.onPressed,
    this.storyCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          color: palette.accent,
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.lg, AppSpacing.screenMargin, AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      completedToday ? 'BRIEF DONE' : "TODAY'S BRIEF",
                      style: AppTypography.overline.copyWith(color: palette.primary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      completedToday ? 'See what you read' : 'Five stories picked for you',
                      style: AppTypography.briefCardHeadline.copyWith(color: palette.onAccent),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      (completedToday ? 'Come back tomorrow for five more' : 'About 4 minutes').toUpperCase(),
                      style: AppTypography.caption.copyWith(color: palette.onAccent.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      completedToday ? 'Open summary →' : 'Start reading →',
                      style: AppTypography.button.copyWith(color: palette.onAccent),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Text(
                '$storyCount'.padLeft(2, '0'),
                style: AppTypography.numeral(56, weight: FontWeight.w900).copyWith(color: palette.primary, height: 0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
