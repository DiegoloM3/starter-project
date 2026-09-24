import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../entities/article_thumbnail.dart';

/// Contract for storing the images attached to articles.
///
/// It is kept apart from `JournalistArticleRepository` because storing binary
/// files and storing article documents are two different responsibilities,
/// backed by two different providers.
abstract class ArticleThumbnailRepository {
  /// Uploads [thumbnail] to the folder owned by [userId] and returns the URL
  /// that must be stored in the article's `thumbnailURL` field.
  Future<DataState<String>> uploadThumbnail({
    required String userId,
    required ArticleThumbnailEntity thumbnail,
  });
}
