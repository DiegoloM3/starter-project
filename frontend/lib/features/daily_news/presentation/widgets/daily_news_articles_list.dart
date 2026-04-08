import 'package:flutter/material.dart';

import '../../domain/entities/article.dart';
import 'article_tile.dart';

class DailyNewsArticlesList extends StatelessWidget {
  final List<ArticleEntity> articles;

  const DailyNewsArticlesList({Key? key, required this.articles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return ArticleWidget(
          article: article,
          onArticlePressed: (a) => Navigator.pushNamed(
            context,
            '/ArticleDetails',
            arguments: a,
          ),
        );
      },
    );
  }
}
