import 'package:equatable/equatable.dart';

import '../../../domain/entities/article_draft.dart';

enum PublishArticleFailureReason { publishFailed, galleryUnavailable }

sealed class PublishArticleState extends Equatable {
  final ArticleDraftEntity draft;

  const PublishArticleState(this.draft);

  /// Whether the journalist has started writing, so leaving must ask what to do with the draft.
  bool get hasStartedWriting => !draft.isBlank;

  /// Field errors to show. Empty until the journalist first tries to publish.
  Set<ArticleDraftError> get visibleErrors => const {};

  @override
  List<Object?> get props => [draft];
}

/// Initial state, and the state the form returns to after any edit.
final class PublishArticleEditing extends PublishArticleState {
  const PublishArticleEditing(super.draft);
}

/// A draft replaced the content of the form: the one resumed when opening it, or a new one after
/// starting over. The form fields show it.
final class PublishArticleDraftLoaded extends PublishArticleState {
  /// Whether it is a draft the journalist left unfinished, rather than a new one.
  final bool isRestored;

  const PublishArticleDraftLoaded(super.draft, {required this.isRestored});

  @override
  List<Object?> get props => [draft, isRestored];
}

final class PublishArticleInvalid extends PublishArticleState {
  final Set<ArticleDraftError> errors;

  const PublishArticleInvalid(super.draft, this.errors);

  @override
  Set<ArticleDraftError> get visibleErrors => errors;

  @override
  List<Object?> get props => [draft, errors];
}

final class PublishArticlePublishing extends PublishArticleState {
  const PublishArticlePublishing(super.draft);
}

final class PublishArticleSuccess extends PublishArticleState {
  const PublishArticleSuccess(super.draft);
}

final class PublishArticleFailure extends PublishArticleState {
  final PublishArticleFailureReason reason;

  const PublishArticleFailure(super.draft, this.reason);

  @override
  List<Object?> get props => [draft, reason];
}
