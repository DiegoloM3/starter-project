import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

/// Shows the dashed "Attach Image" box or, once an image is chosen, its preview.
/// Tapping the preview opens the gallery again so the image can be changed.
class ArticleThumbnailPicker extends StatelessWidget {
  final ArticleThumbnailEntity? thumbnail;
  final VoidCallback? onPick;
  final String? errorText;

  const ArticleThumbnailPicker({
    super.key,
    required this.thumbnail,
    required this.onPick,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final errorText = this.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        thumbnail == null ? _buildAttachBox(palette) : _buildPreview(thumbnail!),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(errorText, style: TextStyle(color: palette.error, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildAttachBox(AppPalette palette) {
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: errorText == null ? palette.dashedBorder : palette.error,
      ),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, size: 28, color: palette.primary),
                const SizedBox(height: 8),
                Text(
                  'Attach Image',
                  style: TextStyle(color: palette.primary, fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ArticleThumbnailEntity thumbnail) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.memory(thumbnail.bytes, fit: BoxFit.cover, width: double.infinity),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: onPick),
            ),
          ),
          const Positioned(right: 10, bottom: 10, child: _ChangeImageLabel()),
        ],
      ),
    );
  }
}

class _ChangeImageLabel extends StatelessWidget {
  const _ChangeImageLabel();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_outlined, size: 14, color: palette.textPrimary),
            const SizedBox(width: 4),
            const Text('Change image', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  static const double _dashLength = 6;
  static const double _gapLength = 4;

  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final border = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)));
    for (final metric in border.computeMetrics()) {
      for (double start = 0; start < metric.length; start += _dashLength + _gapLength) {
        canvas.drawPath(metric.extractPath(start, start + _dashLength), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}
