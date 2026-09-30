import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:news_app_clean_architecture/config/theme/app_themes.dart';

import '../../../../l10n/l10n.dart';
import '../../domain/entities/published_article.dart';

String publishedArticleHeroTag(PublishedArticleEntity article) => 'published-article-${article.id}';

/// List tile of a journalist's article, matching the layout of the news tiles.
class PublishedArticleTile extends StatelessWidget {
  final PublishedArticleEntity article;
  final ValueChanged<PublishedArticleEntity> onPressed;

  const PublishedArticleTile({super.key, required this.article, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPressed(article),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        height: articleTileHeightOf(context),
        child: Row(
          children: [
            _buildImage(context),
            const SizedBox(width: 14),
            Expanded(child: _buildTexts()),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Hero(
      tag: publishedArticleHeroTag(article),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: article.thumbnailUrl,
          width: MediaQuery.of(context).size.width / 3,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) => const _ImagePlaceholder(child: CupertinoActivityIndicator()),
          errorWidget: (_, __, ___) => const _ImagePlaceholder(child: Icon(Icons.broken_image_outlined)),
        ),
      ),
    );
  }

  Widget _buildTexts() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(article.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ),
          PublishedArticleByline(article: article),
        ],
      ),
    );
  }
}

/// "Author · Sep 28, 2026" line shown under article titles, followed by " · 4 min read" when
/// [showsReadingTime] (there is no room for it in the list tiles).
class PublishedArticleByline extends StatelessWidget {
  final PublishedArticleEntity article;
  final bool showsReadingTime;

  const PublishedArticleByline({super.key, required this.article, this.showsReadingTime = false});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(article.publishedAt.toLocal());
    final readingTime = showsReadingTime ? ' · ${context.l10n.readingTime(article.readingTimeInMinutes)}' : '';
    return Row(
      children: [
        const Icon(Icons.edit_note, size: 18),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${article.author} · $date$readingTime',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final Widget child;

  const _ImagePlaceholder({required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: placeholderColorOf(context), child: Center(child: child));
  }
}
