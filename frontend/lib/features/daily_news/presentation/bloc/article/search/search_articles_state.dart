import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';

import '../../../../domain/entities/article.dart';

abstract class SearchArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final AppException? error;

  const SearchArticlesState({this.articles, this.error});

  @override
  List<Object?> get props => [articles, error];
}

class SearchArticlesInitial extends SearchArticlesState {
  const SearchArticlesInitial();
}

class SearchArticlesLoading extends SearchArticlesState {
  const SearchArticlesLoading();
}

class SearchArticlesDone extends SearchArticlesState {
  const SearchArticlesDone(List<ArticleEntity> articles)
      : super(articles: articles);
}

class SearchArticlesFailure extends SearchArticlesState {
  const SearchArticlesFailure(AppException error) : super(error: error);
}
