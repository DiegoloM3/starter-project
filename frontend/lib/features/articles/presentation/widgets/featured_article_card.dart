import 'package:flutter/material.dart';

import '../../domain/entities/article.dart';
import 'article_texts.dart';
import 'article_thumbnail.dart';

/// Big card for the most recent article, at the top of a list.
class FeaturedArticleCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const FeaturedArticleCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArticleThumbnail(imageURL: article.thumbnailURL),
            const SizedBox(height: 16),
            ArticleTopicsText(article: article),
            const SizedBox(height: 8),
            Text(article.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.2)),
            const SizedBox(height: 8),
            Text(article.description, style: textTheme.bodyLarge, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            ArticleMetaText(article: article),
          ],
        ),
      ),
    );
  }
}
