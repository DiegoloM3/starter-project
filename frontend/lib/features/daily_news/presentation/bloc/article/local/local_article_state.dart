import 'package:equatable/equatable.dart';

import '../../../../domain/entities/article.dart';

abstract class LocalArticlesState extends Equatable {
  final List<ArticleEntity>? articles;

  const LocalArticlesState({this.articles});

  @override
  List<Object?> get props => [articles];
}

class LocalArticlesLoading extends LocalArticlesState {
  const LocalArticlesLoading();
}

class LocalArticlesDone extends LocalArticlesState {
  final String? warning;

  const LocalArticlesDone(
    List<ArticleEntity> articles, {
    this.warning,
  }) : super(articles: articles);

  @override
  List<Object?> get props => [articles, warning];
}

class LocalArticlesFailure extends LocalArticlesState {
  final String message;

  const LocalArticlesFailure(
    this.message, {
    super.articles,
  });

  @override
  List<Object?> get props => [articles, message];
}
