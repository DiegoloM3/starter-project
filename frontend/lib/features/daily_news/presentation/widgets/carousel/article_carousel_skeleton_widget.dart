import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/global_themes.dart';

class ArticleCarouselSkeletonWidget extends StatefulWidget {
  const ArticleCarouselSkeletonWidget({super.key});

  @override
  State<ArticleCarouselSkeletonWidget> createState() => _ArticleCarouselSkeletonWidgetState();
}

class _ArticleCarouselSkeletonWidgetState extends State<ArticleCarouselSkeletonWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        height: 220,
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: GlobalTheme.kRule,
      ),
    );
  }
}