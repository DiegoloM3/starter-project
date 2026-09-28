part of 'user_articles_bloc.dart';

/// UI states emitted by [UserArticlesBloc].
abstract class UserArticlesState extends Equatable {
  const UserArticlesState();

  @override
  List<Object?> get props => [];
}

class UserArticlesLoading extends UserArticlesState {
  const UserArticlesLoading();
}

class UserArticlesDone extends UserArticlesState {
  final List<ArticleEntity> articles;

  const UserArticlesDone(this.articles);

  @override
  List<Object?> get props => [articles];
}

class UserArticlesError extends UserArticlesState {
  final String message;

  const UserArticlesError(this.message);

  @override
  List<Object?> get props => [message];
}
