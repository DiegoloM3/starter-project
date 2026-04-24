import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../domain/entities/article.dart';
=======
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
>>>>>>> fbce432 (Finish PR (project setup))

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.only(
<<<<<<< HEAD
            start: 14, end: 14, bottom: 7, top: 7),
=======
          start: 14,
          end: 14,
          bottom: 7,
          top: 7,
        ),
>>>>>>> fbce432 (Finish PR (project setup))
        height: MediaQuery.of(context).size.width / 2.2,
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

<<<<<<< HEAD
  Widget _buildImage(BuildContext context) {
    return CachedNetworkImage(
        imageUrl: article!.urlToImage!,
        imageBuilder: (context, imageProvider) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: double.maxFinite,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.08),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover)),
                ),
              ),
            ),
        progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: double.maxFinite,
                  child: CupertinoActivityIndicator(),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                  ),
                ),
              ),
            ),
        errorWidget: (context, url, error) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: double.maxFinite,
                  child: Icon(Icons.error),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                  ),
                ),
              ),
            ));
=======
  Widget _buildImageContainer({
    required BuildContext context,
    Widget? child,
    DecorationImage? decorationImage,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width / 3,
          height: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.08),
            image: decorationImage,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final url = article?.urlToImage;
    if (url == null) {
      return _buildImageContainer(
        context: context,
        child: const Icon(Icons.image_not_supported),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => _buildImageContainer(
        context: context,
        decorationImage: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      ),
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          _buildImageContainer(
        context: context,
        child: const CupertinoActivityIndicator(),
      ),
      errorWidget: (context, url, error) => _buildImageContainer(
        context: context,
        child: const Icon(Icons.error),
      ),
    );
>>>>>>> fbce432 (Finish PR (project setup))
  }

  Widget _buildTitleAndDescription() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            // Title
            Text(
              article!.title ?? '',
=======
            Text(
              article?.title ?? '',
>>>>>>> fbce432 (Finish PR (project setup))
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Butler',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
<<<<<<< HEAD

            // Description
=======
>>>>>>> fbce432 (Finish PR (project setup))
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
<<<<<<< HEAD
                  article!.description ?? '',
=======
                  article?.description ?? '',
>>>>>>> fbce432 (Finish PR (project setup))
                  maxLines: 2,
                ),
              ),
            ),
<<<<<<< HEAD

            // Datetime
=======
>>>>>>> fbce432 (Finish PR (project setup))
            Row(
              children: [
                const Icon(Icons.timeline_outlined, size: 16),
                const SizedBox(width: 4),
                Text(
<<<<<<< HEAD
                  article!.publishedAt!,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
=======
                  article?.publishedAt ?? '',
                  style: const TextStyle(fontSize: 12),
>>>>>>> fbce432 (Finish PR (project setup))
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemovableArea() {
<<<<<<< HEAD
    if (isRemovable!) {
=======
    if (isRemovable == true) {
>>>>>>> fbce432 (Finish PR (project setup))
      return GestureDetector(
        onTap: _onRemove,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.remove_circle_outline, color: Colors.red),
        ),
      );
    }
<<<<<<< HEAD
    return Container();
=======
    return const SizedBox.shrink();
>>>>>>> fbce432 (Finish PR (project setup))
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
