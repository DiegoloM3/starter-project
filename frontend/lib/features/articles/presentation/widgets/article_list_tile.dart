import 'package:flutter/material.dart';

import '../../domain/entities/article.dart';
import 'article_texts.dart';
import 'article_thumbnail.dart';

/// Compact row with the text on the left and a square thumbnail on the right.
class ArticleListTile extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const ArticleListTile({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _ArticleSummary(article: article)),
            const SizedBox(width: 16),
            SizedBox(width: 96, child: ArticleThumbnail(imageURL: article.thumbnailURL, aspectRatio: 1)),
          ],
        ),
      ),
    );
  }
}

class _ArticleSummary extends StatelessWidget {
  final ArticleEntity article;

  const _ArticleSummary({required this.article});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ArticleTopicsText(article: article),
        const SizedBox(height: 6),
        Text(
          article.title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, height: 1.25),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        ArticleMetaText(article: article),
      ],
    );
  }
}
