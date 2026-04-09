import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

@immutable
sealed class RemoteArticlesEvent {
  const RemoteArticlesEvent();
}

final class GetArticles extends RemoteArticlesEvent {
  const GetArticles();
}

final class CreateArticle extends RemoteArticlesEvent {
  final ArticleEntity article;
  final File image;

  const CreateArticle({
    required this.article,
    required this.image,
  });
}

final class NextPage extends RemoteArticlesEvent {
  const NextPage();
}
