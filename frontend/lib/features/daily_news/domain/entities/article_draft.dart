enum ArticleDraftError {
  emptyTitle,
  titleTooLong,
  emptyContent,
  contentTooLong,
  missingThumbnail,
}

class ArticleDraftEntity {
  static const int maxTitleLength = 100;
  static const int maxContentLength = 5000;

  final String title;
  final String content;
  final String? thumbnailPath;

  const ArticleDraftEntity({
    required this.title,
    required this.content,
    this.thumbnailPath,
  });

  bool get isReadyToPublish => validationErrors.isEmpty;

  List<ArticleDraftError> get validationErrors {
    return [
      if (title.trim().isEmpty) ArticleDraftError.emptyTitle,
      if (title.length > maxTitleLength) ArticleDraftError.titleTooLong,
      if (content.trim().isEmpty) ArticleDraftError.emptyContent,
      if (content.length > maxContentLength) ArticleDraftError.contentTooLong,
      if (thumbnailPath == null) ArticleDraftError.missingThumbnail,
    ];
  }

  @override
  bool operator ==(Object other) {
    return other is ArticleDraftEntity &&
        other.title == title &&
        other.content == content &&
        other.thumbnailPath == thumbnailPath;
  }

  @override
  int get hashCode => Object.hash(title, content, thumbnailPath);
}

class ArticleDraftValidationException implements Exception {
  final List<ArticleDraftError> errors;

  const ArticleDraftValidationException(this.errors);
}
