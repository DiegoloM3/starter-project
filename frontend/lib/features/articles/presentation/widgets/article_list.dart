import 'package:flutter/material.dart';

import '../../domain/entities/article.dart';
import 'article_list_tile.dart';
import 'featured_article_card.dart';

/// Articles separated by lines, with the first one featured.
class ArticleList extends StatelessWidget {
  final List<ArticleEntity> articles;
  final ValueChanged<ArticleEntity> onArticleTap;
  final bool featureFirstArticle;

  const ArticleList({super.key, required this.articles, required this.onArticleTap, this.featureFirstArticle = true});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: articles.length,
      separatorBuilder: (_, _) => const Divider(indent: 16, endIndent: 16),
      itemBuilder: (_, index) => _buildItem(articles[index], isFirst: index == 0),
    );
  }

  Widget _buildItem(ArticleEntity article, {required bool isFirst}) {
    void onTap() => onArticleTap(article);
    if (isFirst && featureFirstArticle) return FeaturedArticleCard(article: article, onTap: onTap);
    return ArticleListTile(article: article, onTap: onTap);
  }
}
