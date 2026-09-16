import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// "LATEST 04" row between two rules, with the last update time on the right.
class FeedSectionHeader extends StatelessWidget {
  final String title;
  final DateTime? updatedAt;
  final int? count;

  const FeedSectionHeader({super.key, required this.title, this.updatedAt, this.count});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.outlineStrong, width: AppRules.strong)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title.toUpperCase(), style: AppTypography.sectionOverline.copyWith(color: palette.ink, fontSize: 13)),
          if (count != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$count'.padLeft(2, '0'),
              style: AppTypography.numeral(13).copyWith(color: palette.outlineStrong),
            ),
          ],
          const Spacer(),
          if (updatedAt != null)
            Text(
              'Updated ${DateFormat.Hm().format(updatedAt!)}'.toUpperCase(),
              style: AppTypography.captionSmall.copyWith(color: palette.inkSecondary),
            ),
        ],
      ),
    );
  }
}
