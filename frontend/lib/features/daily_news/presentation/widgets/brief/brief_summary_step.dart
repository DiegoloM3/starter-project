import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/motion/staggered_entrance.dart';

/// Step 3 of 3, set in paper on ink: what was read and saved as a numbered
/// list between rules, then back to the feed.
class BriefSummaryStep extends StatelessWidget {
  final String firstName;
  final List<ArticleEntity> articles;
  final Set<String> readIds;
  final Set<String> savedIds;
  final int minutes;
  final VoidCallback onBackToFeed;
  final VoidCallback onOpenSaved;

  const BriefSummaryStep({
    super.key,
    required this.firstName,
    required this.articles,
    required this.readIds,
    required this.savedIds,
    required this.minutes,
    required this.onBackToFeed,
    required this.onOpenSaved,
  });

  static const Color _ink = Color(0xFF151413);
  static const Color _paper = Color(0xFFF3F2F2);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final savedCount = articles.where((a) => savedIds.contains(a.id)).length;
    final rule = BorderSide(color: _paper.withValues(alpha: 0.3), width: AppRules.strong);
    return Scaffold(
      backgroundColor: _ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(width: 7, height: 7, color: palette.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text('BRIEF DONE', style: AppTypography.overline.copyWith(color: palette.primary)),
                  const Spacer(),
                  Text('STEP 3 OF 3', style: AppTypography.sectionOverline.copyWith(color: _paper.withValues(alpha: 0.6))),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                "THAT'S YOUR BRIEF, ${firstName.toUpperCase()}.",
                style: AppTypography.briefSummaryTitle.copyWith(color: _paper),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${articles.length} stories · $minutes min · $savedCount saved for later'.toUpperCase(),
                style: AppTypography.caption.copyWith(color: _paper.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(border: Border(top: rule)),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final (index, article) in articles.indexed)
                        StaggeredEntrance(
                          index: index,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(border: Border(bottom: rule)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}'.padLeft(2, '0'),
                                  style: AppTypography.numeral(11).copyWith(color: palette.primary),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    article.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.cardTitle.copyWith(
                                      color: _paper.withValues(alpha: readIds.contains(article.id) ? 1 : 0.6),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Icon(
                                  savedIds.contains(article.id) ? Icons.bookmark_rounded : Icons.check_rounded,
                                  size: 18,
                                  color: savedIds.contains(article.id)
                                      ? palette.primary
                                      : _paper.withValues(alpha: readIds.contains(article.id) ? 0.7 : 0.25),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              FilledButton.icon(
                onPressed: onBackToFeed,
                style: FilledButton.styleFrom(backgroundColor: _paper, foregroundColor: const Color(0xFF201E1D)),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Back to feed'),
              ),
              TextButton(
                onPressed: onOpenSaved,
                style: TextButton.styleFrom(
                  foregroundColor: _paper,
                  minimumSize: const Size.fromHeight(AppSizes.tertiaryButton),
                ),
                child: const Text('Open Saved'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
