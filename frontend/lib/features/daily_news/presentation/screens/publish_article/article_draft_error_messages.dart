import '../../../domain/entities/article_draft.dart';

extension ArticleDraftErrorMessage on ArticleDraftError {
  String get message {
    switch (this) {
      case ArticleDraftError.emptyTitle:
        return 'Please write a title.';
      case ArticleDraftError.titleTooLong:
        return 'The title can have up to ${ArticleDraftEntity.maxTitleLength} characters.';
      case ArticleDraftError.emptyContent:
        return 'Please write the article.';
      case ArticleDraftError.contentTooLong:
        return 'The article can have up to ${ArticleDraftEntity.maxContentLength} characters.';
      case ArticleDraftError.missingThumbnail:
        return 'Please attach an image.';
    }
  }
}
