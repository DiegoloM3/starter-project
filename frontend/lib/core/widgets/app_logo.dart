import 'package:flutter/material.dart';

import '../theme/app_metrics.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 80});

  /// Width and height of the logo in logical pixels (unscaled).
  /// Internally scaled via [AppMetrics.r] for uniform responsiveness.
  final double size;

  @override
  Widget build(BuildContext context) {
    final scaled = AppMetrics.r(size);
    return Container(
      width: scaled,
      height: scaled,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppMetrics.r(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: AppMetrics.r(12),
            offset: Offset(0, AppMetrics.h(4)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.r(16)),
        child: Image.asset(
          'assets/images/logo.png',
          width: scaled,
          height: scaled,
          fit: BoxFit.cover,
          errorBuilder: (context, _, __) => _placeholder(scaled),
        ),
      ),
    );
  }

  Widget _placeholder(double scaled) {
    return Container(
      width: scaled,
      height: scaled,
      color: const Color(0xFFEDE9FE),
      child: Icon(
        Icons.newspaper_rounded,
        size: scaled * 0.5,
        color: const Color(0xFF5B21B6),
      ),
    );
  }
}
