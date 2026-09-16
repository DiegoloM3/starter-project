import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// The Headline News mark. Uses the brand asset and, if it is missing,
/// falls back to an "H" on an ink block so nothing ever breaks.
class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 72});

  static const String assetPath = 'assets/images/brand/headline_news.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'Headline News',
      errorBuilder: (_, _, _) => _FallbackMark(size: size),
    );
  }
}

class _FallbackMark extends StatelessWidget {
  final double size;

  const _FallbackMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: context.palette.accent,
      alignment: Alignment.center,
      child: Text(
        'H',
        style: AppTypography.glyph(size * 0.61, weight: FontWeight.w900).copyWith(color: context.palette.onAccent),
      ),
    );
  }
}
