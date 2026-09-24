import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

/// The cover of an article being written: an invitation when there is none,
/// and the picture itself once there is.
///
/// The empty state is a dashed outline rather than a grey rectangle, because
/// a dashed outline reads as "something goes here" and a grey rectangle reads
/// as "something failed to load".
class CoverImageField extends StatelessWidget {
  final String imageUrl;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const CoverImageField({
    super.key,
    required this.imageUrl,
    required this.isUploading,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _EmptyCover(isUploading: isUploading, onPick: onPick);
    }

    return _FilledCover(
      imageUrl: imageUrl,
      isUploading: isUploading,
      onPick: onPick,
      onRemove: onRemove,
    );
  }
}

class _EmptyCover extends StatelessWidget {
  final bool isUploading;
  final VoidCallback onPick;

  const _EmptyCover({required this.isUploading, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isUploading ? null : onPick,
      child: CustomPaint(
        painter: _DashedBorderPainter(color: AppColors.accent),
        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: Center(
            child: isUploading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 30,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AppLocalizations.of(context).addCoverImage,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AppLocalizations.of(context).recommendedSize,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _FilledCover extends StatelessWidget {
  final String imageUrl;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _FilledCover({
    required this.imageUrl,
    required this.isUploading,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.cardRadius,
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => ColoredBox(
                color: Theme.of(context).dividerColor,
              ),
            ),
            if (isUploading)
              const ColoredBox(
                color: Colors.black45,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CoverAction(
                      label: AppLocalizations.of(context).replace,
                      onPressed: onPick,
                      background: Colors.white,
                      foreground: Colors.black,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _CoverAction(
                      label: AppLocalizations.of(context).remove,
                      onPressed: onRemove,
                      background: AppColors.danger,
                      foreground: Colors.white,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoverAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;

  const _CoverAction({
    required this.label,
    required this.onPressed,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
      child: Text(label),
    );
  }
}

/// Flutter has no dashed border, so it is drawn: a rounded rectangle walked
/// in short strokes.
class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(AppRadius.card),
        ),
      );

    const dash = 6.0;
    const gap = 5.0;

    for (final segment in outline.computeMetrics()) {
      var start = 0.0;

      while (start < segment.length) {
        final end = (start + dash).clamp(0.0, segment.length);
        canvas.drawPath(segment.extractPath(start, end), paint);
        start = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
