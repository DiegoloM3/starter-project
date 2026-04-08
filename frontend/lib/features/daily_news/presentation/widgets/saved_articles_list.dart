import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/article.dart';
import '../bloc/article/local/local_article_bloc.dart';
import '../bloc/article/local/local_article_event.dart';
import 'article_tile.dart';

class SavedArticlesList extends StatelessWidget {
  final List<ArticleEntity> articles;

  const SavedArticlesList({Key? key, required this.articles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const Center(
        child: Text(
          'NO SAVED ARTICLES',
          style: TextStyle(color: Colors.black),
        ),
      );
    }

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return ArticleWidget(
          article: article,
          isRemovable: true,
          onRemove: (a) =>
              context.read<LocalArticleBloc>().add(RemoveArticle(a)),
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
