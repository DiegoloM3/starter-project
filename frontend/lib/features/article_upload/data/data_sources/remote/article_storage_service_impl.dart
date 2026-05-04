import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/remote/article_storage_service.dart';

class ArticleStorageServiceImpl implements ArticleStorageService {
  final FirebaseStorage _storage;

  ArticleStorageServiceImpl(this._storage);

  Reference _thumbnailRef(String articleId) =>
      _storage.ref().child('media/articles/$articleId/thumbnail.jpg');

  @override
  Future<String> uploadThumbnail({
    required String articleId,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      final task = await _thumbnailRef(articleId)
          .putData(bytes, SettableMetadata(contentType: contentType));
      return await task.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw _mapException(e);
    } catch (e, st) {
      throw StorageException(message: e.toString(), cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> deleteThumbnail(String articleId) async {
    try {
      await _thumbnailRef(articleId).delete();
    } on FirebaseException catch (e) {
      throw _mapException(e);
    } catch (e, st) {
      throw StorageException(message: e.toString(), cause: e, stackTrace: st);
    }
  }

  StorageException _mapException(FirebaseException e) {
    return StorageException(
      message: e.message ?? e.code,
      code: e.code,
      cause: e,
    );
  }
}
