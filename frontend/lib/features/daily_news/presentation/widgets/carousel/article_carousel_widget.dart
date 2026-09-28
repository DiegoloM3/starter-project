import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/global_themes.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/shared/widgets/feedback/press_loading_indicator_widget.dart';

class ArticleCarouselWidget extends StatefulWidget {
  final List<ArticleEntity> articles;
  final ValueChanged<ArticleEntity> onArticleTap;

  const ArticleCarouselWidget({
    super.key,
    required this.articles,
    required this.onArticleTap,
  });

  @override
  State<ArticleCarouselWidget> createState() => _ArticleCarouselWidgetState();
}

class _ArticleCarouselWidgetState extends State<ArticleCarouselWidget> {
  static const int _maxFeatured = 5;
  static const Duration _autoAdvanceInterval = Duration(seconds: 4);

  late final List<ArticleEntity> _featured;
  late final PageController _pageController;
  Timer? _autoAdvanceTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _featured = _pickRandomArticles();
    _pageController = PageController();
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<ArticleEntity> _pickRandomArticles() {
    final withImages = widget.articles.where((article) => (article.urlToImage ?? '').isNotEmpty).toList();
    withImages.shuffle();
    return withImages.take(_maxFeatured).toList();
  }

  void _startAutoAdvance() {
    if (_featured.length < 2) return;
    _autoAdvanceTimer = Timer.periodic(_autoAdvanceInterval, (_) => _advancePage());
  }

  void _advancePage() {
    if (!_pageController.hasClients) return;
    final nextPage = (_currentPage + 1) % _featured.length;
    _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    if (_featured.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric( vertical: 8),
      child: _buildPageView(),
    );
  }

  Widget _buildPageView() {
  return LayoutBuilder(
    builder: (context, constraints) {
      return PageView.builder(
        controller: _pageController,
        itemCount: _featured.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) => SizedBox(
          width: constraints.maxWidth,
          child: _buildSlide(context, _featured[index]),
        ),
      );
    },
  );
}
  Widget _buildSlide(BuildContext context, ArticleEntity article) {
  return GestureDetector(
    onTap: () => widget.onArticleTap(article),
    child: Container(
      decoration: BoxDecoration(border: Border.all(color: GlobalTheme.kInk, width: 1.5)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(context, article),
          _buildGradientOverlay(),
          _buildSlideCaption(context, article),
          if (_featured.length > 1) _buildSwipeHint(),
        ],
      ),
    ),
  );
}

  Widget _buildImage(BuildContext context, ArticleEntity article) {
    return CachedNetworkImage(
      imageUrl: article.urlToImage!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: GlobalTheme.kRule,
        child: Center(
          child: PressLoadingIndicatorWidget(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: GlobalTheme.kRule,
        child: Icon(Icons.broken_image, color: GlobalTheme.kInkMuted),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
          stops: const [0.4, 1.0],
        ),
      ),
    );
  }

  Widget _buildSlideCaption(BuildContext context, ArticleEntity article) {
    final baseStyle = GlobalTheme.masthead(Theme.of(context).colorScheme, fontSize: 18);
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        child: Text(
          article.title ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: baseStyle.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSwipeHint() {
    return Positioned(
      right: 12,
      bottom: 10,
      child: Row(
        children: List.generate(_featured.length, _buildHintDot),
      ),
    );
  }

  Widget _buildHintDot(int index) {
    final isActive = index == _currentPage;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: isActive ? 12 : 5,
      height: 5,
      color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
    );
  }
}