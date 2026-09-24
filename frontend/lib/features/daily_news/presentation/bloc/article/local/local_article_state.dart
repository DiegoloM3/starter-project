import 'package:equatable/equatable.dart';

import '../../../../domain/entities/article.dart';

abstract class LocalArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final Object? error;

  const LocalArticlesState({this.articles, this.error});

  /// `articles` is null while loading, so it is compared as nullable. It used
  /// to be forced with `!`, which made comparing two loading states throw —
  /// and bloc compares states on every emit.
  @override
  List<Object?> get props => [articles, error];
}

class LocalArticlesLoading extends LocalArticlesState {
  const LocalArticlesLoading();
}

class LocalArticlesDone extends LocalArticlesState {
  const LocalArticlesDone(List<ArticleEntity> articles)
      : super(articles: articles);
}

/// The saved articles could not be read from, or written to, the device.
class LocalArticlesError extends LocalArticlesState {
  const LocalArticlesError(Object error) : super(error: error);
}
