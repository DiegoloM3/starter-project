import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/presentation/widgets/feed_card.dart';

class FeedCardStack extends StatelessWidget {
  static const double _backCardScale = 0.95;
  static const double _cardHeightFactor = 0.78;
  final List<ArticleEntity> articles;
  final int currentIndex;
  final Set<String> savedArticleIds;
  final String Function(String categoryId) categoryNameResolver;
  final VoidCallback onSwipe;
  final void Function(String articleId) onBookmark;

  const FeedCardStack({
    super.key,
    required this.articles,
    required this.currentIndex,
    required this.savedArticleIds,
    required this.categoryNameResolver,
    required this.onSwipe,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardWidth = screenWidth - AppSpacing.sm * 2;
    final cardHeight = screenHeight * _cardHeightFactor;

    final hasNext = currentIndex + 1 < articles.length;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasNext)
            Transform.translate(
              offset: const Offset(0, AppSpacing.lg),
              child: Transform.scale(
                scale: _backCardScale,
                child: FeedCard(
                  article: articles[currentIndex + 1],
                  categoryName: categoryNameResolver(articles[currentIndex + 1].categoryId),
                  isSaved: savedArticleIds.contains(articles[currentIndex + 1].id),
                  onSwipe: onSwipe,
                  onBookmark: onBookmark,
                ),
              ),
            ),
          FeedCard(
            article: articles[currentIndex],
            categoryName: categoryNameResolver(articles[currentIndex].categoryId),
            isSaved: savedArticleIds.contains(articles[currentIndex].id),
            onSwipe: onSwipe,
            onBookmark: onBookmark,
          ),
        ],
      ),
    );
  }
}
