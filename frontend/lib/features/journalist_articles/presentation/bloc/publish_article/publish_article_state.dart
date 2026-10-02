import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';

/// Every state keeps the [draft], so what the journalist wrote is never lost.
abstract class PublishArticleState extends Equatable {
  final ArticleDraftEntity draft;

  const PublishArticleState(this.draft);

  @override
  List<Object?> get props => [draft];
}

class PublishArticleEditing extends PublishArticleState {
  /// Validation errors are only shown after the journalist tries to publish.
  final bool showsValidationErrors;

  const PublishArticleEditing(super.draft, {this.showsValidationErrors = false});

  @override
  List<Object?> get props => [draft, showsValidationErrors];
}

class PublishArticleInProgress extends PublishArticleState {
  const PublishArticleInProgress(super.draft);
}

class PublishArticleSuccess extends PublishArticleState {
  final JournalistArticleEntity article;

  const PublishArticleSuccess(super.draft, this.article);

  @override
  List<Object?> get props => [draft, article];
}

class PublishArticleFailure extends PublishArticleState {
  final Exception error;

  const PublishArticleFailure(super.draft, this.error);

  @override
  List<Object?> get props => [draft, error];
}
