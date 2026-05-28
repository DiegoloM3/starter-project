import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../config/theme/app_themes.dart';

/// Skeleton placeholder for the FeatureCard — matches its exact layout.
class SkeletonFeatureCard extends StatelessWidget {
  const SkeletonFeatureCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero image skeleton
          Container(height: 185, color: Colors.white),
          // Content skeleton
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title line
                Container(
                  width: double.infinity,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(height: 6),
                // Snippet line 1
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(height: 4),
                // Snippet line 2
                FractionallySizedBox(
                  widthFactor: 0.72,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Author meta row
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 80,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 50,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
