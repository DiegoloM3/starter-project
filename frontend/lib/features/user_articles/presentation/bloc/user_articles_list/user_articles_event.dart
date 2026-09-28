part of 'user_articles_bloc.dart';

@immutable
sealed class UserArticlesEvent extends Equatable {
  const UserArticlesEvent();

  @override
  List<Object?> get props => [];
}

class GetUserArticles extends UserArticlesEvent {
  const GetUserArticles();
}

class DeleteUserArticle extends UserArticlesEvent {
  final UserArticleEntity article;
  const DeleteUserArticle({required this.article});

  @override
  List<Object?> get props => [article];
}
