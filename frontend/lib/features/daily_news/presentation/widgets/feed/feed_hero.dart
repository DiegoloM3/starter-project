import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/relative_time_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/category_label.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/you_badge.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/article_thumbnail.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/hatched_plate.dart';

/// The lead story: a full-width plate (the photo, or hatching when there is
/// none) with a red "LEAD STORY" label, then kicker, headline and dateline.
class FeedHero extends StatelessWidget {
  final ArticleEntity article;
  final bool isOwn;
  final VoidCallback onTap;

  const FeedHero({super.key, required this.article, required this.onTap, this.isOwn = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: palette.outlineStrong, width: AppRules.strong)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: AppSizes.feedHeroHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: ArticleThumbnail.heroTag(article),
                      child: article.hasImage
                          ? CachedNetworkImage(
                              imageUrl: article.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => ColoredBox(color: palette.skeletonBone),
                              errorWidget: (_, _, _) => _Plate(article: article),
                            )
                          : _Plate(article: article),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        color: palette.primary,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 7),
                        child: Text(
                          'LEAD STORY',
                          style: AppTypography.overline.copyWith(color: palette.background),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.lg, AppSpacing.screenMargin, AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        CategoryLabel(category: article.category),
                        if (isOwn) const YouBadge(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(article.title, style: AppTypography.headline.copyWith(color: palette.ink)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${article.author} · ${RelativeTimeFormatter.ago(article.publishedAt)} · ${article.readingTimeMinutes} min'
                          .toUpperCase(),
                      style: AppTypography.caption.copyWith(color: palette.inkSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    return HatchedPlate(
      pitch: 9,
      child: Text(
        article.category.label[0].toUpperCase(),
        style: AppTypography.glyph(110, weight: FontWeight.w900).copyWith(color: context.palette.ink.withValues(alpha: 0.35)),
      ),
    );
  }
}
