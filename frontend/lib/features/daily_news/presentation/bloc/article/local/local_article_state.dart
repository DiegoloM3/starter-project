import 'package:equatable/equatable.dart';

import '../../../../domain/entities/article.dart';

abstract class LocalArticlesState extends Equatable {
  final List<ArticleEntity> ? articles;
  final Exception ? error;

  const LocalArticlesState({this.articles, this.error});

  @override
  List<Object?> get props => [articles, error];
}

class LocalArticlesLoading extends LocalArticlesState {
  const LocalArticlesLoading();
}

class LocalArticlesDone extends LocalArticlesState {
  const LocalArticlesDone(List<ArticleEntity> articles) : super(articles: articles);
}

/// The saved articles could not be read from the phone.
class LocalArticlesError extends LocalArticlesState {
  const LocalArticlesError(Exception error) : super(error: error);
}
