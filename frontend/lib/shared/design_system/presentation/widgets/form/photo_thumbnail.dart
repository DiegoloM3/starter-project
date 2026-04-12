import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';

class PhotoThumbnail extends StatelessWidget {
  final File? file;
  final String? url;
  final VoidCallback onDelete;

  static const double _deleteOverlaySize = 36;
  static const double _deleteOverlayOffset = 4;

  const PhotoThumbnail({
    super.key,
    this.file,
    this.url,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimensions.cardImageStandard,
      height: AppDimensions.cardImageStandard,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: SizedBox.expand(child: _buildImage()),
          ),
          Positioned(
            top: _deleteOverlayOffset,
            right: _deleteOverlayOffset,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: _deleteOverlaySize,
                height: _deleteOverlaySize,
                decoration: const BoxDecoration(
                  color: AppColors.deleteOverlay,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.trash2,
                    size: AppDimensions.iconSm,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (file != null) {
      return Image.file(file!, fit: BoxFit.cover);
    }
    if (url != null) {
      return CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover);
    }
    return const SizedBox.shrink();
  }
}
