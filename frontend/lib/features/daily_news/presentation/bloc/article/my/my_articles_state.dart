import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';

import '../../../../domain/entities/article.dart';

abstract class MyArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final AppException? error;

  const MyArticlesState({this.articles, this.error});

  @override
  List<Object?> get props => [articles, error];
}

class MyArticlesLoading extends MyArticlesState {
  const MyArticlesLoading();
}

class MyArticlesDone extends MyArticlesState {
  const MyArticlesDone(List<ArticleEntity> articles)
      : super(articles: articles);
}

class MyArticlesError extends MyArticlesState {
  const MyArticlesError(AppException error) : super(error: error);
}

class MyArticlesUnauthenticated extends MyArticlesState {
  const MyArticlesUnauthenticated();
}
