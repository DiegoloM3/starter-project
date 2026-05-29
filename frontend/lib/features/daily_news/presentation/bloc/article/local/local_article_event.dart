import 'package:equatable/equatable.dart';

import '../../../../domain/entities/article.dart';

abstract class LocalArticlesEvent extends Equatable {
  final ArticleEntity? article;

  const LocalArticlesEvent({this.article});

  @override
  List<Object?> get props => [article];
}

class SavedArticlesRequested extends LocalArticlesEvent {
  const SavedArticlesRequested();
}

class ArticleRemoved extends LocalArticlesEvent {
  const ArticleRemoved(ArticleEntity article) : super(article: article);
}

class ArticleSaved extends LocalArticlesEvent {
  const ArticleSaved(ArticleEntity article) : super(article: article);
}
