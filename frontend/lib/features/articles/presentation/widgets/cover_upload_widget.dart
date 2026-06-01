import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/l10n/app_localizations.dart';

class CoverUploadWidget extends StatelessWidget {
  final Object? coverVerticalSource;
  final Object? coverHorizontalSource;
  final bool isUploadingVertical;
  final bool isUploadingHorizontal;
  final VoidCallback onTapVertical;
  final VoidCallback onTapHorizontal;

  const CoverUploadWidget({
    super.key,
    this.coverVerticalSource,
    this.coverHorizontalSource,
    this.isUploadingVertical = false,
    this.isUploadingHorizontal = false,
    required this.onTapVertical,
    required this.onTapHorizontal,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _CoverZone(
              label: l10n.coverVerticalLabel,
              aspectRatio: 3 / 4,
              imageSource: coverVerticalSource,
              isUploading: isUploadingVertical,
              onTap: onTapVertical,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 4,
            child: _CoverZone(
              label: l10n.coverHorizontalLabel,
              aspectRatio: 16 / 9,
              imageSource: coverHorizontalSource,
              isUploading: isUploadingHorizontal,
              onTap: onTapHorizontal,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverZone extends StatelessWidget {
  final String label;
  final double aspectRatio;
  final Object? imageSource;
  final bool isUploading;
  final VoidCallback onTap;

  const _CoverZone({
    required this.label,
    required this.aspectRatio,
    this.imageSource,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(AppSpacing.radiusMd),
          child: CustomPaint(
            painter: _DashedBorderPainter(),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    Widget? imageWidget;

    if (imageSource is File) {
      imageWidget = Image.file(
        imageSource as File,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, st) => _emptyZone(),
      );
    } else if (imageSource is String) {
      imageWidget = Image.network(
        imageSource as String,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, st) => _emptyZone(),
      );
    }

    if (imageWidget != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          imageWidget,
          if (isUploading)
            Container(
              color: AppColors.dark.withValues(alpha: 0.26),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      );
    }

    if (isUploading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    return _emptyZone();
  }

  Widget _emptyZone() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.textSecondary,
            size: AppSpacing.iconLg,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderStrong
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final radius = const Radius.circular(AppSpacing.radiusMd);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
