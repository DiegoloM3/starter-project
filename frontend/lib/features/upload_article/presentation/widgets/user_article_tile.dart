import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/widgets/user_avatar.dart';

class UserArticleTile extends StatelessWidget {
  final UserArticleEntity article;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const UserArticleTile({
    super.key,
    required this.article,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.only(
            start: 14, end: 14, bottom: 7, top: 7),
        height: MediaQuery.of(context).size.width / 2.2,
        child: Row(
          children: [
            _buildImage(context),
            _buildTitleAndDescription(),
            if (onDelete != null) _buildDeleteAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final url = article.thumbnailUrl;
    Widget frame({required Widget child}) => Padding(
          padding: const EdgeInsetsDirectional.only(end: 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              width: MediaQuery.of(context).size.width / 3,
              height: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.08),
              ),
              child: child,
            ),
          ),
        );

    if (url == null) {
      return frame(child: const Icon(Icons.image_not_supported_outlined));
    }
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: MediaQuery.of(context).size.width / 3,
            height: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
      progressIndicatorBuilder: (_, __, ___) =>
          frame(child: const CupertinoActivityIndicator()),
      errorWidget: (_, __, ___) => frame(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined,
                color: Colors.grey.shade600, size: 28),
            const SizedBox(height: 6),
            Text(
              'No image',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
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
            Text(
              article.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Butler',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(article.description, maxLines: 2),
              ),
            ),
            Row(
              children: [
                UserAvatar(
                  photoUrl: article.authorPhotoUrl,
                  name: article.authorName ?? article.authorEmail,
                  radius: 10,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${article.byline} · ${DateFormat.yMMMd().format(article.publishedAt)}',
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

  Widget _buildDeleteAction() {
    return GestureDetector(
      onTap: onDelete,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.remove_circle_outline, color: Colors.red),
      ),
    );
  }
}
