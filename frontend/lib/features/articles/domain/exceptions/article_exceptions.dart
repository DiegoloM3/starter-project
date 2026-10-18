import '../params/article_draft.dart';

class ArticleValidationException implements Exception {
  final Set<ArticleValidationError> errors;

  const ArticleValidationException(this.errors);
}

class ArticleNotFoundException implements Exception {
  final String articleId;

  const ArticleNotFoundException(this.articleId);
}
