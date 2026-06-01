import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/shared/widgets/tortutip_skeleton.dart';

class SearchSkeleton extends StatelessWidget {
  const SearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 4,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TortuSkeletonBox(
              width: 52,
              height: 52,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TortuSkeletonBox(width: 80, height: 16),
                  const SizedBox(height: AppSpacing.sm),
                  TortuSkeletonBox(width: double.infinity, height: 14),
                  const SizedBox(height: AppSpacing.xs),
                  TortuSkeletonBox(width: 120, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
