import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/relative_time_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/hatched_plate.dart';

/// One story of the brief, laid out like a front page: the photo (or the
/// hatched plate) as a plate on top, cropped only as much as the width
/// demands, and under a rule the kicker, headline, teaser and the Read /
/// Save blocks on ink. Framed in paper.
class BriefStoryCard extends StatelessWidget {
  final ArticleEntity article;
  final bool isSaved;
  final VoidCallback onRead;
  final VoidCallback onSave;

  /// The stack's controller and this card's page, for the parallax: the
  /// photo drifts with the swipe while the text drifts slightly against it.
  final PageController? parallax;
  final int page;

  /// Reading aloud: whether this card's story is playing, and the toggle.
  final bool isListening;
  final VoidCallback? onListen;

  const BriefStoryCard({
    super.key,
    required this.article,
    required this.isSaved,
    required this.onRead,
    required this.onSave,
    this.parallax,
    this.page = 0,
    this.isListening = false,
    this.onListen,
  });

  static const double photoDrift = 24;
  static const double textDrift = -8;
  static const Color _paper = Color(0xFFF3F2F2);
  static const Color _ink = Color(0xFF151413);

  double _delta() {
    final controller = parallax;
    if (controller == null || !controller.hasClients || !controller.position.haveDimensions) {
      return 0;
    }
    return ((controller.page ?? page.toDouble()) - page).clamp(-1.0, 1.0);
  }

  Widget _drifting(BuildContext context, Widget child, double amount) {
    final controller = parallax;
    if (controller == null || MediaQuery.of(context).disableAnimations) return child;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) => Transform.translate(offset: Offset(0, _delta() * amount), child: child),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(color: _ink, border: Border.all(color: _paper.withValues(alpha: 0.9), width: AppRules.strong)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRect(
              child: _drifting(
                context,
                // A touch larger than the plate so the drift never shows an edge.
                Transform.scale(
                  scale: 1.05,
                  child: article.hasImage
                      ? CachedNetworkImage(
                          imageUrl: article.imageUrl!,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorWidget: (_, _, _) => _Plate(article: article),
                        )
                      : _Plate(article: article),
                ),
                photoDrift,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: _paper, width: AppRules.strong))),
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.lg, AppSpacing.screenMargin, AppSpacing.screenMargin),
            child: _drifting(
              context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: palette.primary,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                    child: Text(
                      '${article.category.label} · ${article.author} · ${RelativeTimeFormatter.ago(article.publishedAt)}'
                          .toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.overline.copyWith(color: _paper),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.briefCardHeadline.copyWith(color: _paper, fontSize: 24, height: 1.1),
                  ),
                  if (article.description case final teaser?) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      teaser,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(color: _paper.withValues(alpha: 0.75)),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onRead,
                          style: FilledButton.styleFrom(
                            backgroundColor: _paper,
                            foregroundColor: const Color(0xFF201E1D),
                            minimumSize: const Size(0, AppSizes.tertiaryButton),
                          ),
                          icon: const Icon(Icons.menu_book_rounded, size: 18),
                          label: const Text('Read'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (onListen != null)
                        IconButton.outlined(
                          onPressed: onListen,
                          tooltip: isListening ? 'Stop' : 'Listen',
                          style: IconButton.styleFrom(
                            foregroundColor: _paper,
                            shape: const RoundedRectangleBorder(),
                            side: BorderSide(color: _paper.withValues(alpha: 0.8), width: AppRules.strong),
                            minimumSize: const Size(AppSizes.tertiaryButton, AppSizes.tertiaryButton),
                          ),
                          icon: Icon(isListening ? Icons.stop_rounded : Icons.volume_up_outlined, size: 20),
                        ),
                      const SizedBox(width: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: onSave,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _paper,
                          side: BorderSide(color: _paper.withValues(alpha: 0.8), width: AppRules.strong),
                          minimumSize: const Size(0, AppSizes.tertiaryButton),
                        ),
                        icon: Icon(isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, size: 18),
                        label: Text(isSaved ? 'Saved' : 'Save'),
                      ),
                    ],
                  ),
                ],
              ),
              textDrift,
            ),
          ),
        ],
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
      pitch: 10,
      child: Text(
        article.category.label[0].toUpperCase(),
        style: AppTypography.glyph(160, weight: FontWeight.w900).copyWith(color: const Color(0xFF201E1D).withValues(alpha: 0.3)),
      ),
    );
  }
}
