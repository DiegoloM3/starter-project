import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/constants/dimens.dart';
import 'package:news_app_clean_architecture/core/extensions/string_extensions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/base_network_image.dart';

class ArticleWidget extends StatelessWidget {
  final ArticleEntity article;
  final bool isRemovable;
  final Function(ArticleEntity article) onRemove;
  final Function(ArticleEntity article) onArticlePressed;

  static const _heightFactor = 2.2;
  static const _titleMaxLines = 3;
  static const _descriptionMaxLines = 2;
  static const _widthFactor = 3;

  const ArticleWidget({
    Key? key,
    required this.article,
    required this.onRemove,
    required this.onArticlePressed,
    required this.isRemovable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onArticlePressed(article),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: Dimens.m,
          vertical: Dimens.s,
        ),
        height: MediaQuery.sizeOf(context).width / _heightFactor,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                end: Dimens.m,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.cardRadius),
                child: BaseNetworkImage(
                  width: MediaQuery.sizeOf(context).width / _widthFactor,
                  height: double.maxFinite,
                  imageUrl: article.url!,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimens.s),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            article.title ?? '',
                            maxLines: _titleMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Butler',
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isRemovable)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: Dimens.xs,
                            ),
                            child: GestureDetector(
                              onTap: () => onRemove(article),
                              child: const Icon(
                                Icons.close,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Description
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: Dimens.xs),
                        child: Text(
                          article.description ?? '',
                          maxLines: _descriptionMaxLines,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Datetime
                    Row(
                      children: [
                        const Icon(
                          Icons.timeline_outlined,
                          size: Dimens.m,
                        ),
                        const SizedBox(width: Dimens.s),
                        Text(
                          article.publishedAt!
                              .toFormattedDate(context: context),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
