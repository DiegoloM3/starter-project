import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_thumbnail.dart';

abstract class ArticleThumbnailRemoteDataSource {
  /// Uploads the thumbnail of the article [articleId] and returns its download URL.
  Future<String> uploadThumbnail(String articleId, ArticleThumbnailModel thumbnail);
}

/// Throws a [FirebaseException] when Cloud Storage cannot complete a request.
class ArticleThumbnailRemoteDataSourceImpl implements ArticleThumbnailRemoteDataSource {
  static const String _folderPath = 'media/articles';

  final FirebaseStorage _storage;

  ArticleThumbnailRemoteDataSourceImpl({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadThumbnail(String articleId, ArticleThumbnailModel thumbnail) async {
    final thumbnailRef = _storage.ref('$_folderPath/$articleId.${thumbnail.fileExtension}');
    await thumbnailRef.putData(thumbnail.bytes, SettableMetadata(contentType: thumbnail.contentType));
    return thumbnailRef.getDownloadURL();
  }
}
