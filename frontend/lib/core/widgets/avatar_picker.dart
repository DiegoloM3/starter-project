import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.imageFile,
    required this.onTap,
    this.size,
  });

  final File? imageFile;
  final VoidCallback onTap;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? 80.r;

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: effectiveSize + 8.r,
          height: effectiveSize + 8.r,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Avatar circle with dashed border ──
              CustomPaint(
                painter: _DashedCirclePainter(
                  color: AppColors.accent,
                  strokeWidth: 1.5.r,
                  dashWidth: 6.r,
                  gapWidth: 4.r,
                ),
                child: SizedBox(
                  width: effectiveSize,
                  height: effectiveSize,
                  child: imageFile != null
                      ? ClipOval(
                          child: Image.file(
                            imageFile!,
                            width: effectiveSize,
                            height: effectiveSize,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            color: AppColors.accentLight,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.person,
                            size: 32.r,
                            color: AppColors.accent,
                          ),
                        ),
                ),
              ),

              // ── Camera badge ──
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 24.r,
                  height: 24.r,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.camera_alt,
                    size: 12.r,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashed circle border painter
// ─────────────────────────────────────────────────────────────────────────────

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.gapWidth,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashWidth + gapWidth)).floor();
    final adjustedDashAngle = (dashWidth / circumference) * 2 * math.pi;
    final adjustedGapAngle =
        (2 * math.pi - adjustedDashAngle * dashCount) / dashCount;

    final rect = Rect.fromCircle(center: center, radius: radius);

    for (var i = 0; i < dashCount; i++) {
      final startAngle =
          i * (adjustedDashAngle + adjustedGapAngle) - math.pi / 2;
      canvas.drawArc(rect, startAngle, adjustedDashAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dashWidth != oldDelegate.dashWidth ||
      gapWidth != oldDelegate.gapWidth;
}
