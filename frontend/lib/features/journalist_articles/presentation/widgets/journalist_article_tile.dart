import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_skeletons.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/config/theme/bookmark_button.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';

import 'comment_count.dart';
import 'package:news_app_clean_architecture/config/theme/publication_date_text.dart';

class JournalistArticleTile extends StatelessWidget {
  static const double _thumbnailSize = 116;

  final JournalistArticleEntity article;
  final void Function(JournalistArticleEntity article) onPressed;

  /// When given (in the saved articles), a filled bookmark removes the article from the list.
  final void Function(JournalistArticleEntity article)? onRemove;

  const JournalistArticleTile({
    super.key,
    required this.article,
    required this.onPressed,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: () => onPressed(article),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          height: _thumbnailSize,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(palette),
              const SizedBox(width: 14),
              Expanded(child: _buildTexts(palette)),
              if (onRemove != null)
                BookmarkButton(isSaved: true, onPressed: () => onRemove!(article), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  /// Without a thumbnail URL (e.g. the placeholder articles of the loading skeleton) nothing is downloaded.
  Widget _buildThumbnail(AppPalette palette) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: _thumbnailSize,
        height: _thumbnailSize,
        color: palette.imagePlaceholder,
        child: article.thumbnailURL.isEmpty
            ? null
            : CachedNetworkImage(
                imageUrl: article.thumbnailURL,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ImageLoadingSkeleton(),
                errorWidget: (_, __, ___) => Icon(Icons.broken_image_outlined, color: palette.icon),
              ),
      ),
    );
  }

  /// Fills the height of the image, with the author, the date and the comments aligned to its bottom edge.
  Widget _buildTexts(AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, height: 1.25),
        ),
        const SizedBox(height: 6),
        Text(
          article.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, height: 1.4, color: palette.textSecondary),
        ),
        const Spacer(),
        Text(
          'By ${article.author}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: PublicationDateText(publishedAt: article.publishedAt)),
            const SizedBox(width: 8),
            CommentCount(count: article.commentCount),
          ],
        ),
      ],
    );
  }
}
