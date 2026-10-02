import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'app_themes.dart';

PaintingEffect _shimmerOf(AppPalette palette) {
  return ShimmerEffect(baseColor: palette.skeletonBase, highlightColor: palette.skeletonHighlight);
}

/// Shows [child] as a shimmering skeleton: the real layout is kept and its texts, icons and images become
/// placeholder "bones" in the colors of the current theme.
class AppSkeletonizer extends StatelessWidget {
  final Widget child;

  const AppSkeletonizer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(effect: _shimmerOf(context.palette), child: child);
  }
}

/// Shimmering placeholder that fills the space where an image is being downloaded.
class ImageLoadingSkeleton extends StatelessWidget {
  const ImageLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      effect: _shimmerOf(context.palette),
      child: const Bone(width: double.infinity, height: double.infinity),
    );
  }
}
