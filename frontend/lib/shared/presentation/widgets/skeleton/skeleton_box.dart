import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:shimmer/shimmer.dart';

/// Wraps skeleton bones in the 1400 ms shimmer sweep. When the platform asks
/// to reduce motion the bones stay static at 60% opacity.
class SkeletonArea extends StatelessWidget {
  final Widget child;

  const SkeletonArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (MediaQuery.of(context).disableAnimations) {
      return Opacity(opacity: 0.6, child: child);
    }
    return Shimmer.fromColors(
      baseColor: palette.skeletonBone,
      highlightColor: palette.skeletonHighlight,
      period: AppMotion.shimmerPeriod,
      child: child,
    );
  }
}

/// A single square bone. Geometry should mirror the real widget it stands for.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: context.palette.skeletonBone,
    );
  }
}
