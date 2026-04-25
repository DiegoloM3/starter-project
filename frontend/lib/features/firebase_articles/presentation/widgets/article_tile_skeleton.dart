import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/constants/colors.dart';
import 'package:news_app_clean_architecture/shared/widgets/shimmer_box.dart';

class ArticleTileSkeleton extends StatelessWidget {
  const ArticleTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final double imageWidth = MediaQuery.of(context).size.width / 3.3;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: AppColors.surface,
      ),
      padding: const EdgeInsetsDirectional.all(7.0),
      height: MediaQuery.of(context).size.width / 3.3,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 14),
            child: ShimmerBox(
              width: imageWidth,
              height: double.maxFinite,
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(height: 16, width: double.infinity),
                      SizedBox(height: 8),
                      ShimmerBox(height: 16, width: 140),
                    ],
                  ),
                  Row(
                    children: const [
                      ShimmerBox(height: 12, width: 90),
                      SizedBox(width: 12),
                      ShimmerBox(height: 12, width: 70),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
