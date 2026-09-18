import '../../domain/entities/article_thumbnail.dart';

abstract class ArticleStorageDataSource {
  Future<String> uploadThumbnail({
    required String storagePath,
    required ArticleThumbnail thumbnail,
  });

  Future<String?> findThumbnailDownloadUrl(String storagePath);
}
