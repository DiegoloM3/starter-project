import '../entities/publishable_article.dart';

enum PublishArticleField {
  author,
  title,
  description,
  content,
  thumbnailFileName,
  thumbnailMimeType,
  thumbnailBytes,
}

class PublishArticleValidationError {
  final PublishArticleField field;
  final String message;

  const PublishArticleValidationError(this.field, this.message);
}

class PublishArticleResult {
  final PublishableArticle? article;
  final List<PublishArticleValidationError> errors;
  final String? pendingArticleId;

  const PublishArticleResult.success(PublishableArticle this.article)
      : errors = const [],
        pendingArticleId = null;

  const PublishArticleResult.confirmationPending(String articleId)
      : article = null,
        errors = const [],
        pendingArticleId = articleId;

  PublishArticleResult.validationFailure(
    List<PublishArticleValidationError> errors,
  )   : article = null,
        pendingArticleId = null,
        errors = List<PublishArticleValidationError>.unmodifiable(errors) {
    if (this.errors.isEmpty) {
      throw ArgumentError.value(errors, 'errors', 'Must not be empty.');
    }
  }
}
