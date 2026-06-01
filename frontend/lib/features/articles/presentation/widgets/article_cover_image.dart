import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/shared/widgets/tortutip_skeleton.dart';

class ArticleCoverImage extends StatelessWidget {
  final String imageUrl;
  final double height;

  const ArticleCoverImage({
    super.key,
    required this.imageUrl,
    this.height = AppSpacing.coverImageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, _) => TortuSkeletonImage(height: height),
      errorWidget: (_, _, _) => Container(
        height: height,
        color: AppColors.surface,
        child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
      ),
    );
  }
}
