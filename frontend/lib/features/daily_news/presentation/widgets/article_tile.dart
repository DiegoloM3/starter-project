import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/presentation/formatters/article_date_formatter.dart';

import '../../domain/entities/article.dart';

class ArticleWidget extends StatelessWidget {
  final ArticleEntity? article;
  final bool? isRemovable;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;

  const ArticleWidget({
    super.key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final currentArticle = article;
    if (currentArticle == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final thumbnailWidth = (constraints.maxWidth * .36).clamp(118.0, 160.0);
        final rowHeight = (constraints.maxWidth * .46).clamp(150.0, 190.0);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onTap,
          child: SizedBox(
            height: rowHeight,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImage(
                    context,
                    currentArticle,
                    thumbnailWidth,
                    rowHeight - 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTitleAndDescription(currentArticle)),
                  _buildRemovableArea(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(
    BuildContext context,
    ArticleEntity currentArticle,
    double width,
    double height,
  ) {
    final imageUrl = currentArticle.urlToImage ?? '';
    if (imageUrl.isEmpty) {
      return _placeholder(width, height);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (_, __, ___) => _placeholder(width, height),
        errorWidget: (_, __, ___) => _placeholder(width, height),
      ),
    );
  }

  Widget _placeholder(double width, double height) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF0ECFA),
        alignment: Alignment.center,
        child: const Icon(Icons.article_outlined, color: Color(0xFF7E6BA8)),
      );

  Widget _buildTitleAndDescription(ArticleEntity currentArticle) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentArticle.title ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 19,
              height: 1.18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 7),
          Expanded(
            child: Text(
              currentArticle.description ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                height: 1.25,
                color: Color(0xFF353535),
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.timeline_outlined, size: 15),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  formatStandardDate(currentArticle.publishedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF454545),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemovableArea() {
    if (isRemovable != true) return const SizedBox.shrink();
    return GestureDetector(
      onTap: _onRemove,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.remove_circle_outline, color: Colors.red),
      ),
    );
  }

  void _onTap() {
    final currentArticle = article;
    if (currentArticle != null && onArticlePressed != null) {
      onArticlePressed!(currentArticle);
    }
  }

  void _onRemove() {
    final currentArticle = article;
    if (currentArticle != null && onRemove != null) {
      onRemove!(currentArticle);
    }
  }
}
