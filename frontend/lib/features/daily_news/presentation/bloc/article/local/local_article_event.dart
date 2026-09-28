part of 'local_article_bloc.dart';

@immutable
sealed class LocalArticlesEvent extends Equatable {
  const LocalArticlesEvent();

  @override
  List<Object?> get props => [];
}

class GetSavedArticles extends LocalArticlesEvent {
  const GetSavedArticles();
}

class RemoveArticle extends LocalArticlesEvent {
  final ArticleEntity article;
  const RemoveArticle({required this.article});

  @override
  List<Object?> get props => [article];
}

class SaveArticle extends LocalArticlesEvent {
  final ArticleEntity article;
  const SaveArticle({required this.article});

  @override
  List<Object?> get props => [article];
}