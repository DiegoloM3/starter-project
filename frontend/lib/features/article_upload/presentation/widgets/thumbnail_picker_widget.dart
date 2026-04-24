import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/config/theme/theme.dart';

class ThumbnailPickerWidget extends StatefulWidget {
  final String? thumbnailUrl;
  final bool isLoading;
  final ValueChanged<String> onImagePicked;

  const ThumbnailPickerWidget({
    Key? key,
    this.thumbnailUrl,
    required this.isLoading,
    required this.onImagePicked,
  }) : super(key: key);

  @override
  State<ThumbnailPickerWidget> createState() => _ThumbnailPickerWidgetState();
}

class _ThumbnailPickerWidgetState extends State<ThumbnailPickerWidget> {
  String? _localPath;

  @override
  void didUpdateWidget(ThumbnailPickerWidget old) {
    super.didUpdateWidget(old);
    if (old.thumbnailUrl != null && widget.thumbnailUrl == null) {
      setState(() => _localPath = null);
    }
  }

  Future<void> _pick() async {
    await HapticFeedback.lightImpact();
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _localPath = picked.path);
      widget.onImagePicked(picked.path);
    }
  }

  bool get _hasImage => _localPath != null || widget.thumbnailUrl != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : _pick,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: _hasImage ? 180 : 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.accentLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) return _buildLoading();
    if (_localPath != null) return _buildLocalPreview();
    if (widget.thumbnailUrl != null) return _buildNetworkPreview();
    return _buildEmpty();
  }

  Widget _buildEmpty() {
    return CustomPaint(
      painter: _DashedRectPainter(color: AppColors.accent, borderRadius: AppRadius.md),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, color: AppColors.accent, size: 18),
          SizedBox(width: 8),
          Text(
            'Add cover image',
            style: TextStyle(color: AppColors.accent, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
    );
  }

  Widget _buildLocalPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        kIsWeb
            ? Image.network(_localPath!, fit: BoxFit.cover)
            : Image.file(File(_localPath!), fit: BoxFit.cover),
        _buildEditOverlay(),
      ],
    );
  }

  Widget _buildNetworkPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(widget.thumbnailUrl!, fit: BoxFit.cover),
        _buildEditOverlay(),
      ],
    );
  }

  Widget _buildEditOverlay() {
    return Positioned(
      bottom: AppSpacing.sm,
      right: AppSpacing.sm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, color: Colors.white, size: 13),
            SizedBox(width: AppSpacing.xs),
            Text('Change', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  const _DashedRectPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
        Radius.circular(borderRadius),
      ));

    canvas.drawPath(_buildDashPath(path, 6.0, 4.0), paint);
  }

  Path _buildDashPath(Path source, double dashWidth, double dashSpace) {
    final Path dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dest.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(_DashedRectPainter old) =>
      old.color != color || old.borderRadius != borderRadius;
}
