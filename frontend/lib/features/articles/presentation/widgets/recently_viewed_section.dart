import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/article.dart';
import '../bloc/reading_history/reading_history_cubit.dart';
import 'article_thumbnail.dart';

/// Horizontal list of the last articles viewed. Hidden while there are none.
class RecentlyViewedSection extends StatelessWidget {
  final ValueChanged<ArticleEntity> onArticleTap;

  const RecentlyViewedSection({super.key, required this.onArticleTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadingHistoryCubit, List<ArticleEntity>>(
      builder: (context, articles) {
        if (articles.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'VISTOS RECIENTEMENTE',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: articles.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder:
                    (_, index) =>
                        _ViewedArticleCard(article: articles[index], onTap: () => onArticleTap(articles[index])),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ViewedArticleCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const _ViewedArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArticleThumbnail(imageURL: article.thumbnailURL),
            const SizedBox(height: 8),
            Text(
              article.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
