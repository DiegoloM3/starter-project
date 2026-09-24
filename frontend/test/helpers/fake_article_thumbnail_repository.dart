import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_thumbnail_repository.dart';

/// Hand written test double for [ArticleThumbnailRepository].
class FakeArticleThumbnailRepository implements ArticleThumbnailRepository {
  DataState<String> uploadResult = const DataSuccess('https://mock/upload.jpg');

  int uploadCallCount = 0;
  String? lastUserId;
  ArticleThumbnailEntity? lastThumbnail;

  @override
  Future<DataState<String>> uploadThumbnail({
    required String userId,
    required ArticleThumbnailEntity thumbnail,
  }) async {
    uploadCallCount++;
    lastUserId = userId;
    lastThumbnail = thumbnail;
    return uploadResult;
  }
}
