import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/paths.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';

class ArticlesList extends StatelessWidget {
  const ArticlesList({
    super.key,
    required this.articles,
    this.scrollController,
    this.isLast = true,
    this.isRemovable = false,
    this.onRemove,
  });

  final ScrollController? scrollController;
  final bool isRemovable;
  final bool isLast;
  final List<ArticleEntity> articles;
  final Function(ArticleEntity)? onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: articles.length,
      physics: const AlwaysScrollableScrollPhysics(),
      cacheExtent: 500,
      itemBuilder: (context, index) {
        if (index == articles.length - 1 && !isLast) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RepaintBoundary(
          child: ArticleWidget(
            article: articles[index],
            isRemovable: isRemovable,
            onArticlePressed: (article) => context.pushNamed(
              Paths.articleDetails.name,
              extra: article,
            ),
            onRemove: (article) {
              if (isRemovable) {
                onRemove?.call(article);
              }
            },
          ),
        );
      },
    );
  }
}
