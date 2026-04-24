import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:news_app_clean_architecture/config/theme/theme.dart';

/// Shimmer placeholder that mirrors ArticleWidget layout.
class ArticleTileShimmer extends StatelessWidget {
  const ArticleTileShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: 90, height: 90, radius: AppRadius.sm),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: double.infinity, height: 14, radius: 4),
                  SizedBox(height: AppSpacing.xs),
                  _ShimmerBox(width: double.infinity, height: 14, radius: 4),
                  SizedBox(height: AppSpacing.xs),
                  _ShimmerBox(width: 120, height: 12, radius: 4),
                  SizedBox(height: AppSpacing.sm),
                  _ShimmerBox(width: 80, height: 11, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
