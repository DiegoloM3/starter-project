import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_skeletons.dart';
import '../../../../config/theme/app_themes.dart';
import '../../../../config/theme/bookmark_button.dart';
import '../../../../config/theme/publication_date_text.dart';
import '../../domain/entities/article.dart';

/// A news article in a list. With [onRemove], it shows a filled bookmark to take it out of the saved news.
class ArticleTile extends StatelessWidget {
  static const double _thumbnailSize = 116;

  final ArticleEntity article;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;

  const ArticleTile({
    super.key,
    required this.article,
    this.onArticlePressed,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: () => onArticlePressed?.call(article),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          height: _thumbnailSize,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(palette),
              const SizedBox(width: 14),
              Expanded(child: _buildTitleAndDescription(palette)),
              _buildRemoveButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Without an image URL (e.g. the placeholder articles of the loading skeleton) nothing is downloaded.
  Widget _buildImage(AppPalette palette) {
    final imageUrl = article.urlToImage ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: _thumbnailSize,
        height: _thumbnailSize,
        color: palette.imagePlaceholder,
        child: imageUrl.isEmpty
            ? null
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ImageLoadingSkeleton(),
                errorWidget: (_, __, ___) => Icon(Icons.image_outlined, color: palette.icon),
              ),
      ),
    );
  }

  /// Fills the height of the image, with the date aligned to its bottom edge.
  Widget _buildTitleAndDescription(AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.title ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, height: 1.25),
        ),
        const SizedBox(height: 6),
        Text(
          article.description ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, height: 1.4, color: palette.textSecondary),
        ),
        const Spacer(),
        ArticlePublicationDate(publishedAt: article.publishedAt),
      ],
    );
  }

  Widget _buildRemoveButton() {
    final onRemove = this.onRemove;
    if (onRemove == null) return const SizedBox.shrink();
    return BookmarkButton(isSaved: true, onPressed: () => onRemove(article), size: 22);
  }
}

/// The date of a news article. NewsAPI sends ISO dates ("2026-09-29T18:00:00Z"); anything else is shown as it comes.
class ArticlePublicationDate extends StatelessWidget {
  final String? publishedAt;

  const ArticlePublicationDate({super.key, required this.publishedAt});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(publishedAt ?? '');
    if (date != null) return PublicationDateText(publishedAt: date);
    return Text(publishedAt ?? '', style: TextStyle(fontSize: 12, color: context.palette.textSecondary));
  }
}
