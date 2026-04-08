import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../domain/entities/article.dart';
import '../bloc/article/local/local_article_bloc.dart';
import '../bloc/article/local/local_article_event.dart';

class SaveArticleFab extends StatelessWidget {
  final ArticleEntity article;

  const SaveArticleFab({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () {
          context.read<LocalArticleBloc>().add(SaveArticle(article));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.black,
              content: Text('Article saved successfully.'),
            ),
          );
        },
        child: const Icon(Ionicons.bookmark, color: Colors.white),
      ),
    );
  }
}
