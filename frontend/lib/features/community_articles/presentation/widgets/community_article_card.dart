import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/emulator_image_url.dart';
import '../../../../core/utils/format_published_at.dart';
import '../../../daily_news/domain/entities/article.dart';

class CommunityArticleCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const CommunityArticleCard({
    Key? key,
    required this.article,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = article.title ?? '(untitled)';
    final description = article.description ?? '';
    final imageUrl = article.urlToImage;
    final publishedAt = formatPublishedAt(article.publishedAt);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: rewriteEmulatorImageUrl(imageUrl),
                height: 180,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 180,
                  color: const Color(0xFFEEEEEE),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 180,
                  color: const Color(0xFFEEEEEE),
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined,
                      color: Color(0xFF9E9E9E)),
                ),
              )
            else
              Container(
                height: 100,
                color: const Color(0xFFF5F5F5),
                alignment: Alignment.center,
                child: const Icon(Icons.article_outlined,
                    size: 40, color: Color(0xFF9E9E9E)),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    publishedAt,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
