import 'package:equatable/equatable.dart';

import '../../../../domain/entities/article.dart';

abstract class LocalArticlesEvent extends Equatable {
  const LocalArticlesEvent();

  @override
  List<Object?> get props => [];
}

class GetSavedArticles extends LocalArticlesEvent {
  const GetSavedArticles();
}

class RemoveArticle extends LocalArticlesEvent {
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
}
