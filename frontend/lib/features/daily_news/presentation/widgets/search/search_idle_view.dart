import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// What Search shows before typing: recent queries between rules and the
/// sections as a numbered two-column grid.
class SearchIdleView extends StatelessWidget {
  final List<String> recent;
  final ValueChanged<String> onRecentTap;
  final VoidCallback onClearRecent;
  final ValueChanged<NewsCategory> onTopicTap;

  const SearchIdleView({
    super.key,
    required this.recent,
    required this.onRecentTap,
    required this.onClearRecent,
    required this.onTopicTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final rule = BorderSide(color: palette.outlineStrong, width: AppRules.strong);
    final soft = BorderSide(color: palette.outline, width: AppRules.strong);
    final sections = NewsCategory.values.where((c) => c != NewsCategory.general).toList();
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ListView(
      padding: EdgeInsets.only(bottom: bottomInset + AppSpacing.xxl),
      children: [
        if (recent.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, 4, AppSpacing.sm, 4),
            decoration: BoxDecoration(border: Border(top: rule, bottom: rule)),
            child: Row(
              children: [
                Expanded(child: Text('RECENT', style: AppTypography.sectionOverline.copyWith(color: palette.ink))),
                TextButton(onPressed: onClearRecent, child: const Text('Clear all')),
              ],
            ),
          ),
          for (final query in recent)
            InkWell(
              onTap: () => onRecentTap(query),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin, vertical: 15),
                decoration: BoxDecoration(border: Border(bottom: soft)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(query, style: AppTypography.valueLine.copyWith(color: palette.ink, fontSize: 16)),
                    ),
                    Icon(Icons.north_west_rounded, size: 16, color: palette.inkSecondary),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, 0, AppSpacing.screenMargin, AppSpacing.md),
          child: Text('SECTIONS', style: AppTypography.sectionOverline.copyWith(color: palette.ink)),
        ),
        Container(
          decoration: BoxDecoration(border: Border(top: rule)),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.9),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final category = sections[index];
              return InkWell(
                onTap: () => onTopicTap(category),
                hoverColor: palette.surface,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border(bottom: rule, right: index.isEven ? rule : BorderSide.none),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${index + 1}'.padLeft(2, '0'), style: AppTypography.numeral(11).copyWith(color: palette.primary)),
                      Text(
                        category.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.cardTitle.copyWith(color: palette.ink, fontSize: 17),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
