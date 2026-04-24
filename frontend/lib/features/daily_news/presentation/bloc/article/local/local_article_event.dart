import 'package:equatable/equatable.dart';
<<<<<<< HEAD

import '../../../../domain/entities/article.dart';

abstract class LocalArticlesEvent extends Equatable {
  final ArticleEntity ? article;

  const LocalArticlesEvent({this.article});

  @override
  List<Object> get props => [article!];
=======
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class LocalArticlesEvent extends Equatable {
  const LocalArticlesEvent();

  @override
  List<Object?> get props => [];
>>>>>>> fbce432 (Finish PR (project setup))
}

class GetSavedArticles extends LocalArticlesEvent {
  const GetSavedArticles();
}

class RemoveArticle extends LocalArticlesEvent {
<<<<<<< HEAD
  const RemoveArticle(ArticleEntity article) : super(article: article);
}

class SaveArticle extends LocalArticlesEvent {
  const SaveArticle(ArticleEntity article) : super(article: article);
=======
  final ArticleEntity article;
  const RemoveArticle(this.article);

  @override
  List<Object?> get props => [article];
}

class SaveArticle extends LocalArticlesEvent {
  final ArticleEntity article;
  const SaveArticle(this.article);

  @override
  List<Object?> get props => [article];
>>>>>>> fbce432 (Finish PR (project setup))
}
