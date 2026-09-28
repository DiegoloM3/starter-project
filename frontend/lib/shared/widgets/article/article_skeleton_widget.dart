

import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/global_themes.dart';

class ArticleSkeletonWidget extends StatefulWidget {
  const ArticleSkeletonWidget({super.key});

  @override
  State<ArticleSkeletonWidget> createState() => _ArticleSkeletonWidgetState();
}

class _ArticleSkeletonWidgetState extends State<ArticleSkeletonWidget>
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
        padding: const EdgeInsetsDirectional.only(start: 14, end: 14, bottom: 7, top: 7),
        height: MediaQuery.of(context).size.width / 2.2,
        child: Row(
          children: [
            _buildImagePlaceholder(context),
            Expanded(child: _buildTextPlaceholder()),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        color: GlobalTheme.kRule,
        ),
        width: MediaQuery.of(context).size.width / 3,
        height: double.maxFinite,
      ),
    );
  }

  Widget _buildTextPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 18, width: double.infinity, color: GlobalTheme.kRule),
          const SizedBox(height: 8),
          Container(height: 18, width: 200, color: GlobalTheme.kRule),
          const Spacer(),
          Container(height: 12, width: 100, color: GlobalTheme.kRule),
        ],
      ),
    );
  }
}