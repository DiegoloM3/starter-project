import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/article_thumbnail.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/hatched_plate.dart';

/// 250dp plate at the top of the article: the photo edge to edge, or the
/// hatched plate with the category initial when there is none, closed by
/// the 2px ink rule. Shares its Hero tag with the feed thumbnail.
class ReaderHero extends StatelessWidget {
  final ArticleEntity article;

  const ReaderHero({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: palette.ink, width: AppRules.strong))),
      child: Hero(
        tag: ArticleThumbnail.heroTag(article),
        child: SizedBox(
          height: AppSizes.heroHeight,
          width: double.infinity,
          child: article.hasImage
              ? CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => ColoredBox(color: palette.skeletonBone),
                  errorWidget: (_, _, _) => _Plate(article: article),
                )
              : _Plate(article: article),
        ),
      ),
    );
  }
}

class _Plate extends StatelessWidget {
  final ArticleEntity article;

  const _Plate({required this.article});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return HatchedPlate(
      pitch: 9,
      child: Text(
        article.category.label[0].toUpperCase(),
        style: AppTypography.glyph(120, weight: FontWeight.w900).copyWith(color: palette.ink.withValues(alpha: 0.35)),
      ),
    );
  }
}
