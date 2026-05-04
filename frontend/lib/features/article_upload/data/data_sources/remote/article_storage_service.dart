import 'dart:typed_data';

abstract class ArticleStorageService {
  /// Uploads bytes to media/articles/{articleId}/thumbnail.jpg.
  /// Returns the public download URL.
  Future<String> uploadThumbnail({
    required String articleId,
    required Uint8List bytes,
    required String contentType,
  });

  Future<void> deleteThumbnail(String articleId);
}
