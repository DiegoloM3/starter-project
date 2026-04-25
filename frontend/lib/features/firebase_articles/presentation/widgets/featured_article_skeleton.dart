import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/constants/colors.dart';
import 'package:news_app_clean_architecture/core/constants/dimensions.dart';
import 'package:news_app_clean_architecture/shared/widgets/shimmer_box.dart';

class FeaturedArticleSkeleton extends StatelessWidget {
  const FeaturedArticleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Column(
        children: [
          ShimmerBox(
            height: 300,
            width: double.infinity,
            borderRadius: BorderRadius.circular(40),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 15,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(height: 20, width: double.infinity),
                const SizedBox(height: 8),
                const ShimmerBox(height: 20, width: 200),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ShimmerBox(
                      height: 24,
                      width: 24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(width: 8),
                    const ShimmerBox(height: 14, width: 100),
                    const Spacer(),
                    const ShimmerBox(height: 14, width: 80),
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
