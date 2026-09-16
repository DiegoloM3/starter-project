import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/hatched_plate.dart';

/// "Photo (optional)": a hatched 72dp plate to tap until a picture is
/// chosen, then a framed 150dp preview with a labelled Remove block. During
/// upload a scrim and a progress ring cover the preview.
class PhotoField extends StatelessWidget {
  final String? localPath;
  final String? remoteUrl;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const PhotoField({
    super.key,
    required this.localPath,
    required this.remoteUrl,
    required this.isUploading,
    required this.onPick,
    required this.onRemove,
  });

  bool get hasPhoto => localPath != null || remoteUrl != null;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Photo',
            style: AppTypography.label.copyWith(color: palette.ink),
            children: [
              TextSpan(
                text: ' (optional)',
                style: AppTypography.label.copyWith(color: palette.inkSecondary, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!hasPhoto)
          InkWell(
            onTap: onPick,
            child: HatchedPlate(
              height: AppSizes.smallThumb,
              bordered: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                color: palette.background,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, color: palette.primary, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Add a photo', style: AppTypography.button.copyWith(color: palette.ink)),
                  ],
                ),
              ),
            ),
          )
        else
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(border: Border.all(color: palette.ink, width: AppRules.strong)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (localPath != null)
                  Image.file(File(localPath!), fit: BoxFit.cover)
                else
                  CachedNetworkImage(imageUrl: remoteUrl!, fit: BoxFit.cover),
                if (isUploading)
                  ColoredBox(
                    color: palette.ink.withValues(alpha: 0.55),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(color: palette.primary, strokeWidth: 3),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text('UPLOADING PHOTO…', style: AppTypography.overline.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  )
                else
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: LabeledIconButton(
                      icon: Icons.close_rounded,
                      label: 'Remove',
                      backgroundColor: palette.glass,
                      onPressed: onRemove,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
