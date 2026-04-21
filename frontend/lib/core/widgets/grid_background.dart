import 'package:flutter/material.dart';

class GridBackground extends StatelessWidget {
  final Widget child;
  final double spacing;
  final Color? lineColor;

  const GridBackground({
    super.key,
    required this.child,
    this.spacing = 40,
    this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: CustomPaint(
        painter: _GridPainter(
          spacing: spacing,
          color: lineColor ?? Colors.black.withValues(alpha: 0.045),
        ),
        child: child,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double spacing;
  final Color color;

  _GridPainter({required this.spacing, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.spacing != spacing || old.color != color;
}
