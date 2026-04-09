import 'package:flutter/material.dart';

import '../../domain/entities/article.dart';
import 'article_description.dart';
import 'article_image.dart';
import 'article_title_and_date.dart';

class ArticleDetailBody extends StatelessWidget {
  final ArticleEntity article;

  const ArticleDetailBody({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ArticleTitleAndDate(
            title: article.title!,
            publishedAt: article.publishedAt!,
          ),
          ArticleImage(imageUrl: article.urlToImage),
          ArticleDescription(
            description: article.description ?? '',
            content: article.content ?? '',
          ),
        ],
      ),
    );
  }
}
