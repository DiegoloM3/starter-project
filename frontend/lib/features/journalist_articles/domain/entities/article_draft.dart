import 'package:news_app_clean_architecture/core/util/value_equality.dart';

import 'article_thumbnail.dart';

enum ArticleDraftError { blank, tooLong, missing, unsupportedType, tooLarge }

/// Article written by a journalist that has not been published yet. Its author is the signed-in journalist,
/// so the draft does not ask for it.
///
/// Its rules mirror the schema enforced by the backend (backend/docs/DB_SCHEMA.md),
/// so an invalid article is detected before it reaches Firebase.
class ArticleDraftEntity with ValueEquality {
  static const int maxTitleLength = 150;
  static const int maxDescriptionLength = 300;
  static const int maxContentLength = 20000;

  final String title;
  final String description;
  final String content;
  final ArticleThumbnailEntity? thumbnail;

  const ArticleDraftEntity({
    this.title = '',
    this.description = '',
    this.content = '',
    this.thumbnail,
  });

  ArticleDraftEntity copyWith({
    String? title,
    String? description,
    String? content,
    ArticleThumbnailEntity? thumbnail,
  }) {
    return ArticleDraftEntity(
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  ArticleDraftError? get titleError => _findTextError(title, maxTitleLength);

  ArticleDraftError? get descriptionError =>
      _findTextError(description, maxDescriptionLength);

  ArticleDraftError? get contentError =>
      _findTextError(content, maxContentLength);

  ArticleDraftError? get thumbnailError {
    final thumbnail = this.thumbnail;
    if (thumbnail == null) return ArticleDraftError.missing;
    if (!thumbnail.hasAllowedExtension) return ArticleDraftError.unsupportedType;
    if (!thumbnail.isWithinMaxSize) return ArticleDraftError.tooLarge;
    return null;
  }

  bool get isValid => [
        titleError,
        descriptionError,
        contentError,
        thumbnailError,
      ].every((error) => error == null);

  static ArticleDraftError? _findTextError(String value, int maxLength) {
    if (value.trim().isEmpty) return ArticleDraftError.blank;
    if (value.length > maxLength) return ArticleDraftError.tooLong;
    return null;
  }

  @override
  List<Object?> get props => [title, description, content, thumbnail];
}

/// Thrown when trying to publish an [ArticleDraftEntity] that breaks its rules.
class InvalidArticleDraftException implements Exception {
  final ArticleDraftEntity draft;

  const InvalidArticleDraftException(this.draft);
}
