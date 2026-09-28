part of 'user_articles_bloc.dart';

/// Events consumed by [UserArticlesBloc].
abstract class UserArticlesEvent extends Equatable {
  const UserArticlesEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserArticles extends UserArticlesEvent {
  const LoadUserArticles();
}
