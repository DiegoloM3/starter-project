import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';

abstract class SavedJournalistArticlesState extends Equatable {
  const SavedJournalistArticlesState();

  @override
  List<Object?> get props => [];
}

class SavedJournalistArticlesInProgress extends SavedJournalistArticlesState {
  const SavedJournalistArticlesInProgress();
}

class SavedJournalistArticlesSuccess extends SavedJournalistArticlesState {
  final List<JournalistArticleEntity> articles;

  const SavedJournalistArticlesSuccess(this.articles);

  @override
  List<Object?> get props => [articles];
}

/// The journalist has just removed an article from the list.
class SavedJournalistArticleRemoved extends SavedJournalistArticlesSuccess {
  const SavedJournalistArticleRemoved(super.articles);
}

/// Removing an article failed, so the list stays as it was.
class SavedJournalistArticleRemoveFailure extends SavedJournalistArticlesSuccess {
  final Exception error;

  const SavedJournalistArticleRemoveFailure(super.articles, this.error);

  @override
  List<Object?> get props => [articles, error];
}

class SavedJournalistArticlesFailure extends SavedJournalistArticlesState {
  final Exception error;

  const SavedJournalistArticlesFailure(this.error);

  @override
  List<Object?> get props => [error];
}
