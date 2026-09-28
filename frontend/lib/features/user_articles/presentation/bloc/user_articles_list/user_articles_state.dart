part of 'user_articles_bloc.dart';

@immutable
sealed class UserArticlesState extends Equatable {
  const UserArticlesState();

  @override
  List<Object?> get props => [];
}

class UserArticlesLoading extends UserArticlesState {
  const UserArticlesLoading();
}

class UserArticlesDone extends UserArticlesState {
  final List<UserArticleEntity> articles;
  const UserArticlesDone({required this.articles});

  @override
  List<Object?> get props => [articles];
}

class UserArticlesError extends UserArticlesState {
  final String message;
  final bool showSnackbar;

  const UserArticlesError({required this.message, this.showSnackbar = false});

  @override
  List<Object?> get props => [message, showSnackbar];
}