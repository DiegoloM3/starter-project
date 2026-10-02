import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

/// Text shown to the journalist for each rule an [ArticleDraftEntity] can break.
extension ArticleDraftErrorMessage on ArticleDraftError {
  String get message {
    switch (this) {
      case ArticleDraftError.blank:
        return 'This field is required';
      case ArticleDraftError.tooLong:
        return 'This field is too long';
      case ArticleDraftError.missing:
        return 'Attach a thumbnail for the article';
      case ArticleDraftError.unsupportedType:
        return 'Use a JPG, PNG or WEBP image';
      case ArticleDraftError.tooLarge:
        return 'The image must be ${ArticleThumbnailEntity.maxSizeInBytes ~/ (1024 * 1024)} MB or smaller';
    }
  }
}
