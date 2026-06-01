import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';

class ArticleResultCard extends StatelessWidget {
  final ArticleEntity article;
  final String query;
  final String categoryName;
  final VoidCallback onTap;

  const ArticleResultCard({
    super.key,
    required this.article,
    required this.query,
    required this.categoryName,
    required this.onTap,
  });

  static List<TextSpan> highlightMatches(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    int idx = lowerText.indexOf(lowerQuery, start);

    while (idx != -1) {
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: const TextStyle(
          backgroundColor: Color(0xFFEAF3DE),
          color: Color(0xFF3B6D11),
          fontWeight: FontWeight.bold,
        ),
      ));
      start = idx + query.length;
      idx = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: CachedNetworkImage(
                imageUrl: article.coverVerticalUrl,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorWidget: (ctx, url, err) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.surface,
                  child: const Icon(Icons.image, color: AppColors.textTertiary),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      categoryName,
                      style: AppTypography.caption,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: AppTypography.body,
                      children: highlightMatches(article.title, query),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${article.authorName} · ${article.readTimeMinutes} min',
                    style: AppTypography.caption,
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
