/// Business rule that an article breaks.
///
/// Errors are reported as values instead of messages so that the presentation
/// layer stays in charge of wording and translating them.
enum ArticleValidationError {
  titleRequired,
  titleTooLong,
  descriptionRequired,
  descriptionTooLong,
  contentRequired,
  thumbnailRequired,
  authorRequired,
  userRequired,
}

/// Business rule that an article thumbnail breaks.
enum ThumbnailValidationError {
  emptyFile,
  fileTooLarge,
  unsupportedFormat,
}

/// Returned by the use cases when an article does not satisfy its business
/// rules.
class ArticleValidationException implements Exception {
  final List<ArticleValidationError> errors;

  const ArticleValidationException(this.errors);

  @override
  String toString() => 'ArticleValidationException($errors)';
}

/// Returned by the use cases when a thumbnail does not satisfy its business
/// rules.
class ThumbnailValidationException implements Exception {
  final List<ThumbnailValidationError> errors;

  const ThumbnailValidationException(this.errors);

  @override
  String toString() => 'ThumbnailValidationException($errors)';
}

/// Returned when an operation targets an article that does not exist.
class ArticleNotFoundException implements Exception {
  final String articleId;

  const ArticleNotFoundException(this.articleId);

  @override
  String toString() => 'ArticleNotFoundException($articleId)';
}

/// Returned when an operation that only makes sense on a stored article (such
/// as updating or publishing it) receives one that was never saved.
class ArticleNotStoredException implements Exception {
  const ArticleNotStoredException();

  @override
  String toString() => 'ArticleNotStoredException()';
}
