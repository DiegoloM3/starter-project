import 'package:equatable/equatable.dart';

import '../../../../domain/entities/article.dart';

sealed class RemoteArticlesState extends Equatable {
  const RemoteArticlesState();

  @override
  List<Object?> get props => [];
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

class RemoteArticlesDone extends RemoteArticlesState {
  final List<ArticleEntity> articles;

  const RemoteArticlesDone(this.articles);

  @override
  List<Object?> get props => [articles];
}

class RemoteArticlesError extends RemoteArticlesState {
  final Exception error;

  const RemoteArticlesError(this.error);

  @override
  List<Object?> get props => [error];
}
