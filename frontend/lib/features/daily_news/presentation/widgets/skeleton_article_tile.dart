import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../config/theme/app_themes.dart';

class SkeletonArticleTile extends StatelessWidget {
  final bool showDivider;

  const SkeletonArticleTile({Key? key, this.showDivider = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.border,
          highlightColor: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 62,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        width: double.infinity,
                        height: 13,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      const SizedBox(height: 5),
                      FractionallySizedBox(
                        widthFactor: 0.6,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 13,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 40,
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
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.border),
          ),
      ],
    );
  }
}
