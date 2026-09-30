import 'article_draft.dart';

/// Returned (inside a DataFailed) when a draft that breaks the publishing rules is published.
class InvalidArticleDraftException implements Exception {
  final Set<ArticleDraftError> errors;

  const InvalidArticleDraftException(this.errors);

  @override
  String toString() => 'InvalidArticleDraftException($errors)';
}
