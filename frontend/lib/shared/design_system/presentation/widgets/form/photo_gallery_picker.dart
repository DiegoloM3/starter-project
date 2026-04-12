import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';
import 'package:news_app_clean_architecture/core/resources/image_item.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/form/photo_thumbnail.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/ui_elements/form_field_label.dart';

class PhotoGalleryPicker extends StatelessWidget {
  final String label;
  final List<ImageItem> images;
  final bool canAddMore;
  final VoidCallback onAddPhotoTapped;
  final ValueChanged<int> onImageRemoved;
  final String hintText;

  const PhotoGalleryPicker({
    super.key,
    required this.label,
    required this.images,
    required this.canAddMore,
    required this.onAddPhotoTapped,
    required this.onImageRemoved,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FormFieldLabel(label: label),
        const SizedBox(height: AppDimensions.spacing10),
        SizedBox(
          height: AppDimensions.cardImageStandard,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...images.asMap().entries.map((entry) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(right: AppDimensions.spacing12),
                    child: PhotoThumbnail(
                      file: entry.value.file,
                      url: entry.value.url,
                      onDelete: () => onImageRemoved(entry.key),
                    ),
                  );
                }),
                if (canAddMore) _AddPhotoButton(onTap: onAddPhotoTapped),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacing8),
        Text(
          hintText,
          style: AppTypography.footnote.copyWith(
            color: context.colors.textPlaceholder,
          ),
        ),
      ],
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: colors.borderSubtle,
          strokeWidth: AppDimensions.dashedStrokeWidth,
          borderRadius: AppDimensions.radiusMd,
        ),
        child: Container(
          width: AppDimensions.cardImageStandard,
          height: AppDimensions.cardImageStandard,
          decoration: BoxDecoration(
            color: colors.bgCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Center(
            child: Icon(
              LucideIcons.plus,
              size: AppDimensions.iconXxl,
              color: colors.textPlaceholder,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end =
            (distance + AppDimensions.dashWidth).clamp(0.0, metric.length);
        dashPath.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += AppDimensions.dashWidth + AppDimensions.dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth || borderRadius != oldDelegate.borderRadius;
}
