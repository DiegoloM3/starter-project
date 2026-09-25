import 'dart:async';

import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/app_image.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

import '../../domain/entities/article.dart';
import 'article_actions.dart';

/// Big photo cards swiped sideways, with dots showing which one is on
/// screen. Moves on to the next card by itself every few seconds.
class FeaturedCarousel extends StatefulWidget {
  final List<ArticleEntity> articles;
  final ValueChanged<ArticleEntity> onArticlePressed;

  /// See [AppImage.isOffline].
  final bool isOffline;

  const FeaturedCarousel({
    super.key,
    required this.articles,
    required this.onArticlePressed,
    this.isOffline = false,
  });

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  // Below 1 so the next card peeks in, hinting there's more to swipe.
  final _controller = PageController(viewportFraction: 0.88);
  int _page = 0;

  static const _autoAdvanceEvery = Duration(seconds: 4);
  Timer? _autoAdvance;

  @override
  void initState() {
    super.initState();
    _restartAutoAdvance();
  }

  @override
  void dispose() {
    _autoAdvance?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // Restarted on every page change, so a card the reader just swiped to
  // gets its full few seconds before the next one comes.
  void _restartAutoAdvance() {
    _autoAdvance?.cancel();
    if (widget.articles.length < 2) return;
    _autoAdvance = Timer(_autoAdvanceEvery, _advance);
  }

  void _advance() {
    if (!mounted || !_controller.hasClients) return;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    final next = (_page + 1) % widget.articles.length;
    unawaited(_controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // A 16:10 photo, as wide as the peeking page allows: about a third of
    // the screen, so the day's stories start right below it.
    final cardWidth = MediaQuery.sizeOf(context).width * 0.88 - 12;
    final height = (cardWidth * 10 / 16).clamp(200.0, 320.0);
    return Column(
      children: [
        SizedBox(
          height: height,
          // Holds still while the reader's finger is on it.
          child: Listener(
            onPointerDown: (_) => _autoAdvance?.cancel(),
            onPointerUp: (_) => _restartAutoAdvance(),
            onPointerCancel: (_) => _restartAutoAdvance(),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.articles.length,
              onPageChanged: (page) {
                setState(() => _page = page);
                _restartAutoAdvance();
              },
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _FeaturedCard(
                  article: widget.articles[index],
                  onTap: () => widget.onArticlePressed(widget.articles[index]),
                  isOffline: widget.isOffline,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _PageDots(count: widget.articles.length, current: _page),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;
  final bool isOffline;

  const _FeaturedCard({
    required this.article,
    required this.onTap,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const onPhoto = Colors.white;
    // The summary only when there's room for it: small phones and large
    // system fonts keep headline and byline, which matter more.
    final roomForSummary = MediaQuery.sizeOf(context).width >= 380 &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.15;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(url: article.urlToImage, isOffline: isOffline),
              // Darkens the lower part so white text reads on any photo.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.2, 0.55, 1],
                    colors: [
                      Colors.transparent,
                      Color(0x66000000),
                      Color(0xF0000000),
                    ],
                  ),
                ),
              ),
              if ((article.sourceName ?? '').isNotEmpty)
                Positioned(
                  top: 12,
                  left: 12,
                  // Leaves room for the bookmark on the right.
                  right: 60,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _SourceChip(name: article.sourceName!),
                  ),
                ),
              // Always the same corner, whatever the source's name length.
              Positioned(
                top: 8,
                right: 8,
                child: BookmarkButton(article: article, onPhoto: true),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(color: onPhoto, height: 1.25),
                    ),
                    if (roomForSummary &&
                        (article.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        article.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: onPhoto.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            article.author ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium
                                ?.copyWith(color: onPhoto),
                          ),
                        ),
                        Text(
                          '${context.l10n.readStory} →',
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: onPhoto),
                        ),
                      ],
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

class _SourceChip extends StatelessWidget {
  final String name;

  const _SourceChip({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        name.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall
            ?.copyWith(color: theme.colorScheme.onPrimary),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int current;

  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == current
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
