import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/utils/date_formatter.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/article/domain/entities/article.dart';
import '../../../../shared/widgets/app_cached_image.dart';

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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: AppColors.surface,
        ),
        padding: const EdgeInsetsDirectional.all(
          7.0,
        ),
        height: MediaQuery.of(context).size.width / 3.3,
        child: Row(
          children: [
            _buildImage(context),
            _buildTitleAndDescription(),
            _buildRemovableArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final double imageWidth = MediaQuery.of(context).size.width / 3.3;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 14),
      child: AppCachedImage(
        imageUrl: article!.urlToImage ?? '',
        width: imageWidth,
        height: double.maxFinite,
        borderRadius: BorderRadius.circular(20.0),
        heroTag: article!.heroTag,
      ),
    );
  }

  Widget _buildTitleAndDescription() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title
            Text(
              article!.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Butler',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.titleDark,
              ),
            ),

            // Datetime
            Row(
              children: [
                Expanded(
                  child: Row(
                    spacing: 6,
                    children: [
                      const Icon(Icons.calendar_month, size: 16),
                      Expanded(
                        child: Text(
                          DateFormatter.format(
                            article!.publishedAt!,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (article!.author != null && article!.author!.isNotEmpty)
                  Expanded(
                      child: Row(
                    spacing: 6,
                    children: [
                      const Icon(Icons.person, size: 16),
                      Expanded(
                        child: Text(
                          article!.author ?? 'Unknown Author',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemovableArea() {
    if (isRemovable!) {
      return GestureDetector(
        onTap: _onRemove,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.remove_circle_outline, color: AppColors.error),
        ),
      );
    }
    return Container();
  }

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
}
