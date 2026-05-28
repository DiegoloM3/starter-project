import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';

import '../../../../domain/entities/article.dart';

abstract class PublishedArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final AppException? error;

  const PublishedArticlesState({this.articles, this.error});

  @override
  List<Object?> get props => [articles, error];
}

class PublishedArticlesLoading extends PublishedArticlesState {
  const PublishedArticlesLoading();
}

class PublishedArticlesDone extends PublishedArticlesState {
  const PublishedArticlesDone(List<ArticleEntity> articles)
      : super(articles: articles);
}

class PublishedArticlesFailure extends PublishedArticlesState {
  const PublishedArticlesFailure(AppException error)
      : super(error: error);
}
