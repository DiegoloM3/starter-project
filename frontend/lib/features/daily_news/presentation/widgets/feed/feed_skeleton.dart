import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/skeleton/skeleton_box.dart';

/// Bones that mirror the lead story and the rows 1:1 while the first load runs.
class FeedSkeleton extends StatelessWidget {
  final int rows;

  const FeedSkeleton({super.key, this.rows = 4});

  @override
  Widget build(BuildContext context) {
    return SkeletonArea(
      child: Column(
        children: [
          const SkeletonBox(height: AppSizes.feedHeroHeight),
          const Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.lg, AppSpacing.screenMargin, AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 90, height: 10),
                SizedBox(height: AppSpacing.md),
                SkeletonBox(height: 28),
                SizedBox(height: AppSpacing.xs),
                SkeletonBox(width: 220, height: 28),
                SizedBox(height: AppSpacing.md),
                SkeletonBox(width: 160, height: 11),
              ],
            ),
          ),
          for (var i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.rowHorizontal,
                vertical: AppSpacing.rowVertical,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 72, height: 10),
                        SizedBox(height: AppSpacing.sm),
                        SkeletonBox(height: 18),
                        SizedBox(height: AppSpacing.xs),
                        SkeletonBox(width: 180, height: 18),
                        SizedBox(height: AppSpacing.sm),
                        SkeletonBox(width: 120, height: 11),
                      ],
                    ),
                  ),
                  if (i.isEven) ...[
                    const SizedBox(width: 14),
                    const SkeletonBox(width: AppSizes.thumb, height: AppSizes.thumb),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
