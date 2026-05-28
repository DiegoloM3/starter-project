import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';

import '../../../../domain/entities/article.dart';

abstract class UserArticlesFilter {
  static const String all = 'all';
  static const String drafts = 'drafts';
  static const String published = 'published';
  static const String archived = 'archived';
}

abstract class UserArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final AppException? error;
  final String filter;

  const UserArticlesState({
    this.articles,
    this.error,
    this.filter = UserArticlesFilter.all,
  });

  @override
  List<Object?> get props => [articles, error, filter];
}

class UserArticlesLoading extends UserArticlesState {
  const UserArticlesLoading({String filter = UserArticlesFilter.all})
      : super(filter: filter);
}

class UserArticlesDone extends UserArticlesState {
  const UserArticlesDone(
    List<ArticleEntity> articles, {
    String filter = UserArticlesFilter.all,
  }) : super(articles: articles, filter: filter);
}

class UserArticlesFailure extends UserArticlesState {
  const UserArticlesFailure(
    AppException error, {
    String filter = UserArticlesFilter.all,
  }) : super(error: error, filter: filter);
}
