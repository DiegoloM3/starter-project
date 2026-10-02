import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';

abstract class PublishedArticlesState extends Equatable {
  const PublishedArticlesState();

  @override
  List<Object?> get props => [];
}

class PublishedArticlesInProgress extends PublishedArticlesState {
  const PublishedArticlesInProgress();
}

class PublishedArticlesSuccess extends PublishedArticlesState {
  final List<JournalistArticleEntity> articles;

  const PublishedArticlesSuccess(this.articles);

  @override
  List<Object?> get props => [articles];
}

class PublishedArticlesFailure extends PublishedArticlesState {
  final Exception error;

  const PublishedArticlesFailure(this.error);

  @override
  List<Object?> get props => [error];
}
