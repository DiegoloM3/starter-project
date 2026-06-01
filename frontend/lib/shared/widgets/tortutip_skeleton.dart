import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';

class TortuSkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;

  const TortuSkeletonBox({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.border,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
    );
  }
}

class TortuSkeletonImage extends StatelessWidget {
  final double? height;

  const TortuSkeletonImage({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return TortuSkeletonBox(width: double.infinity, height: height);
  }
}
