import 'package:flutter/material.dart';
import '../../domain/entities/article.dart';
import 'article_tile_image.dart';
import 'article_tile_removable_area.dart';
import 'article_tile_title_and_description.dart';

class ArticleWidget extends StatelessWidget {
  final ArticleEntity? article;
  final bool? isRemovable;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;

  const ArticleWidget({
    Key? key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
  }) : super(key: key);

  void _onTap() {
    if (onArticlePressed != null) {
      onArticlePressed!(article!);
    }
  }

  void _onRemove() {
    if (onRemove != null) {
      onRemove!(article!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.only(
            start: 14, end: 14, bottom: 7, top: 7),
        height: MediaQuery.of(context).size.width / 2.2,
        child: Row(
          children: [
            ArticleTileImage(imageUrl: article!.urlToImage),
            ArticleTileTitleAndDescription(
              title: article!.title ?? '',
              description: article!.description ?? '',
              publishedAt: article!.publishedAt!,
            ),
            ArticleTileRemovableArea(
              isRemovable: isRemovable ?? false,
              onRemove: _onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
