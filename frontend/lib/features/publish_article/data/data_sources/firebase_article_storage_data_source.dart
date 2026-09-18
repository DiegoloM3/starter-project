import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/entities/article_thumbnail.dart';
import 'article_storage_data_source.dart';
import 'publication_data_source_exception.dart';

/// SDK operations kept here so tests can replace I/O without Firebase setup.
abstract class ArticleStorageClient {
  Future<void> putData(String path, Uint8List bytes, SettableMetadata metadata);
  Future<String> getDownloadUrl(String path);
}

class _FirebaseArticleStorageClient implements ArticleStorageClient {
  final FirebaseStorage _storage;

  _FirebaseArticleStorageClient(this._storage);

  @override
  Future<void> putData(
      String path, Uint8List bytes, SettableMetadata metadata) async {
    await _storage.ref(path).putData(bytes, metadata);
  }

  @override
  Future<String> getDownloadUrl(String path) =>
      _storage.ref(path).getDownloadURL();
}

class FirebaseArticleStorageDataSource implements ArticleStorageDataSource {
  final ArticleStorageClient _client;

  FirebaseArticleStorageDataSource(FirebaseStorage storage)
      : _client = _FirebaseArticleStorageClient(storage);

  /// Internal I/O boundary for deterministic data-layer tests.
  FirebaseArticleStorageDataSource.withClient(this._client);

  @override
  Future<String> uploadThumbnail({
    required String storagePath,
    required ArticleThumbnail thumbnail,
  }) async {
    try {
      await _client.putData(storagePath, Uint8List.fromList(thumbnail.bytes),
          SettableMetadata(contentType: thumbnail.mimeType));
    } on FirebaseException catch (error) {
      throw _sdkException(
          error, PublicationDataSourceOperation.uploadThumbnail);
    }
    // A completed upload whose URL cannot be retrieved is still a failure.
    // Only findThumbnailDownloadUrl treats a missing object as a null result.
    try {
      return await _client.getDownloadUrl(storagePath);
    } on FirebaseException catch (error) {
      throw _sdkException(
          error, PublicationDataSourceOperation.getThumbnailDownloadUrl);
    }
  }

  @override
  Future<String?> findThumbnailDownloadUrl(String storagePath) async {
    try {
      return await _client.getDownloadUrl(storagePath);
    } on FirebaseException catch (error) {
      if (error.code == 'object-not-found') return null;
      throw _sdkException(
          error, PublicationDataSourceOperation.getThumbnailDownloadUrl);
    }
  }

  PublicationDataSourceException _sdkException(
      FirebaseException error, PublicationDataSourceOperation operation) {
    return PublicationDataSourceException(
      source: PublicationDataSource.storage,
      operation: operation,
      code: error.code,
      message: error.message ?? 'Storage operation failed.',
      cause: error,
    );
  }
}
