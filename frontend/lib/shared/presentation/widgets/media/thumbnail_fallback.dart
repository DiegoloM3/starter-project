import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/hatched_plate.dart';

/// Tile shown where an image is required but the article has none: the
/// hatched plate with the category initial at ~46% of the tile.
class ThumbnailFallback extends StatelessWidget {
  final String categoryLabel;
  final double size;

  const ThumbnailFallback({
    super.key,
    required this.categoryLabel,
    required this.size,
  });

  String get _initial => categoryLabel.isEmpty ? 'N' : categoryLabel[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    return HatchedPlate(
      width: size,
      height: size,
      bordered: true,
      child: Text(
        _initial,
        style: AppTypography.glyph(size * 0.46, weight: FontWeight.w900).copyWith(color: context.palette.ink),
      ),
    );
  }
}
