import '../../../domain/params/article_draft.dart';

extension ArticleValidationMessage on ArticleValidationError {
  String get message => switch (this) {
    ArticleValidationError.titleEmpty => 'Escribe un título.',
    ArticleValidationError.titleTooLong => 'Máximo ${ArticleLimits.titleMaxLength} caracteres.',
    ArticleValidationError.descriptionEmpty => 'Escribe una descripción.',
    ArticleValidationError.descriptionTooLong => 'Máximo ${ArticleLimits.descriptionMaxLength} caracteres.',
    ArticleValidationError.contentEmpty => 'El artículo no tiene contenido.',
    ArticleValidationError.contentTooLong => 'El artículo es demasiado largo.',
    ArticleValidationError.noTopics => 'Elige al menos un tema.',
    ArticleValidationError.tooManyTopics => 'Elige como máximo ${ArticleLimits.maxTopics} temas.',
    ArticleValidationError.imageEmpty => 'Añade una imagen de portada.',
    ArticleValidationError.imageTooLarge =>
      'La imagen debe pesar menos de ${ArticleLimits.imageMaxBytes ~/ (1024 * 1024)} MB.',
  };
}

/// The message of the first error that belongs to a field, or null when the field is valid.
String? messageForField(Set<ArticleValidationError> errors, Set<ArticleValidationError> fieldErrors) {
  for (final error in errors) {
    if (fieldErrors.contains(error)) return error.message;
  }
  return null;
}

const titleErrors = {ArticleValidationError.titleEmpty, ArticleValidationError.titleTooLong};
const descriptionErrors = {ArticleValidationError.descriptionEmpty, ArticleValidationError.descriptionTooLong};
const contentErrors = {ArticleValidationError.contentEmpty, ArticleValidationError.contentTooLong};
const topicErrors = {ArticleValidationError.noTopics, ArticleValidationError.tooManyTopics};
const thumbnailErrors = {ArticleValidationError.imageEmpty, ArticleValidationError.imageTooLarge};
