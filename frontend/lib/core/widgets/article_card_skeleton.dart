import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import 'skeleton_loader.dart';

class ArticleCardSkeleton extends StatelessWidget {
  const ArticleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppMetrics.h(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left content placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    SkeletonLoader(
                      width: AppMetrics.w(60),
                      height: AppMetrics.h(12),
                    ),
                    SizedBox(height: AppMetrics.h(8)),

                    // Title line 1
                    SkeletonLoader(
                      width: double.infinity,
                      height: AppMetrics.h(16),
                    ),
                    SizedBox(height: AppMetrics.h(6)),

                    // Title line 2
                    SkeletonLoader(
                      width: AppMetrics.w(250),
                      height: AppMetrics.h(16),
                    ),
                    SizedBox(height: AppMetrics.h(8)),

                    // Excerpt line 1
                    SkeletonLoader(
                      width: double.infinity,
                      height: AppMetrics.h(12),
                    ),
                    SizedBox(height: AppMetrics.h(4)),

                    // Excerpt line 2
                    SkeletonLoader(
                      width: AppMetrics.w(220),
                      height: AppMetrics.h(12),
                    ),
                    SizedBox(height: AppMetrics.h(10)),

                    // Meta row
                    Row(
                      children: [
                        SkeletonLoader(
                          width: AppMetrics.w(80),
                          height: AppMetrics.h(10),
                        ),
                        const Spacer(),
                        SkeletonLoader(
                          width: AppMetrics.w(40),
                          height: AppMetrics.h(10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppMetrics.w(12)),

              // Thumbnail placeholder
              SkeletonLoader(
                width: 80.r,
                height: 80.r,
                borderRadius: 8.r,
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.border, height: 1),
      ],
    );
  }
}
