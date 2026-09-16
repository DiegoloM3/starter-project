import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';

/// The grey plate that stands where a photo would be: diagonal hatching on a
/// flat tone, the way a layout marks an image slot. Optionally holds a child
/// (an initial, a label) on top.
class HatchedPlate extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  /// Spacing between hatch lines; the hero uses a wider one than a thumb.
  final double pitch;
  final bool bordered;

  const HatchedPlate({
    super.key,
    this.width,
    this.height,
    this.child,
    this.pitch = 7,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: palette.plate,
        border: bordered ? Border.all(color: palette.outlineStrong, width: AppRules.soft) : null,
      ),
      child: CustomPaint(
        painter: _HatchPainter(color: palette.hatch, pitch: pitch),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  final Color color;
  final double pitch;

  const _HatchPainter({required this.color, required this.pitch});

  @override
  void paint(Canvas canvas, Size size) {
    // CustomPaint does not clip: without this the strokes run past the plate.
    canvas.clipRect(Offset.zero & size);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    // 135° lines: start along the top edge and the left edge, run down-left.
    final span = size.width + size.height;
    for (var x = 0.0; x < span; x += pitch) {
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) => oldDelegate.color != color || oldDelegate.pitch != pitch;
}
