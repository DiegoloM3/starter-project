import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/avatar/author_avatar_cubit.dart';
import 'package:news_app_clean_architecture/features/news/presentation/widgets/article_author_row.dart';

/// Reusable article card used by feeds and saved lists.
class ArticleWidget extends StatelessWidget {
  final ArticleEntity? article;
  final bool? isRemovable;
  static final Logger log = Logger("ArticleWidget");
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;
  final AuthorAvatarCubit Function()? avatarCubitFactory;
  final Widget? trailing;

  const ArticleWidget({
    super.key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
    this.avatarCubitFactory,
    this.trailing,
  });

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
            _buildImage(context),
            _buildTitleAndDescription(),
            _buildRemovableArea(),
            _buildTrailing(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final double imageWidth = MediaQuery.of(context).size.width / 3;
    // Soft grey background used in all image placeholder states.
    final Color placeholderColor = Colors.black.withValues(alpha: 0.08);

    final String urlImage = article?.urlToImage ??
        "https://img.magnific.com/free-vector/news-grunge-text_460848-9369.jpg?semt=ais_hybrid&w=740&q=80";

    return CachedNetworkImage(
      imageUrl: urlImage,
      // Decode bound: the tile shows ~1/3 screen width, so a full camera
      // photo must never be decoded at native resolution here.
      memCacheWidth: 400,
      imageBuilder: (context, imageProvider) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: imageWidth,
            height: double.maxFinite,
            decoration: BoxDecoration(
              color: placeholderColor,
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: imageWidth,
            height: double.maxFinite,
            decoration: BoxDecoration(color: placeholderColor),
            child: const CupertinoActivityIndicator(),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: imageWidth,
            height: double.maxFinite,
            decoration: BoxDecoration(color: placeholderColor),
            child: const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndDescription() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              article!.title ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Butler',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),

            // Description
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  article!.content ?? '',
                  maxLines: 2,
                ),
              ),
            ),

            // Author
            _buildAuthorRow(),

            // Datetime
            Row(
              children: [
                const Icon(Icons.timeline_outlined, size: 16),
                const SizedBox(width: 4),
                // User-created articles store full ISO-8601 timestamps,
                // which overflowed this row on narrow screens — constrain
                // and ellipsize instead.
                Expanded(
                  child: Text(
                    article?.publishedAt ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: ArticleAuthorRow(
        authorId: article?.authorId,
        authorDisplayName: article?.authorDisplayName,
        avatarCubitFactory: avatarCubitFactory,
      ),
    );
  }

  Widget _buildRemovableArea() {
    if (isRemovable == true) {
      return GestureDetector(
        onTap: _onRemove,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.remove_circle_outline, color: Colors.red),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTrailing() {
    return trailing ?? const SizedBox.shrink();
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
