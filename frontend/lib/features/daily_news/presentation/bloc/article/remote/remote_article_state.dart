part of 'remote_article_bloc.dart';

@immutable
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
  const RemoteArticlesDone({required this.articles});

  @override
  List<Object?> get props => [articles];
}

class RemoteArticlesError extends RemoteArticlesState {
  final Exception error;
  const RemoteArticlesError({required this.error});

  @override
  List<Object?> get props => [error];
}