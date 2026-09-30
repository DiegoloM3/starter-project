import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../../../domain/entities/article_thumbnail.dart';

/// Article thumbnails in Cloud Storage: `media/articles/{articleId}.{extension}`
/// (see backend/docs/DB_SCHEMA.md and backend/storage.rules).
///
/// Every operation has a time limit and throws a [TimeoutException] past it. The SDK's retry
/// times (set in injection_container.dart) only limit retries after errors: a request the server
/// accepts but never answers, on a hanging backend or a very poor network, would wait forever.
class ArticleThumbnailStorageDataSource {
  static const String _folder = 'media/articles';

  final FirebaseStorage _storage;
  final Duration _uploadTimeLimit;
  final Duration _requestTimeLimit;

  ArticleThumbnailStorageDataSource(
    this._storage, {
    Duration uploadTimeLimit = const Duration(seconds: 30),
    Duration requestTimeLimit = const Duration(seconds: 15),
  })  : _uploadTimeLimit = uploadTimeLimit,
        _requestTimeLimit = requestTimeLimit;

  /// Cancels the upload when it takes longer than its time limit.
  Future<void> uploadThumbnail(String articleId, ArticleThumbnailEntity thumbnail) async {
    final metadata = SettableMetadata(contentType: _contentTypeOf(thumbnail));
    final upload = _referenceFor(articleId, thumbnail).putFile(File(thumbnail.localPath), metadata);
    try {
      await upload.timeout(_uploadTimeLimit);
    } on TimeoutException {
      await upload.cancel();
      rethrow;
    }
  }

  Future<String> getThumbnailUrl(String articleId, ArticleThumbnailEntity thumbnail) {
    return _referenceFor(articleId, thumbnail).getDownloadURL().timeout(_requestTimeLimit);
  }

  /// Only allowed by the rules while no article document uses the thumbnail (orphan cleanup).
  Future<void> deleteThumbnail(String articleId, ArticleThumbnailEntity thumbnail) {
    return _referenceFor(articleId, thumbnail).delete().timeout(_requestTimeLimit);
  }

  Reference _referenceFor(String articleId, ArticleThumbnailEntity thumbnail) {
    return _storage.ref('$_folder/$articleId.${thumbnail.extension}');
  }

  String _contentTypeOf(ArticleThumbnailEntity thumbnail) {
    return thumbnail.extension == 'jpg' ? 'image/jpeg' : 'image/${thumbnail.extension}';
  }
}
