import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/params/publish_article_params.dart';
import '../models/publishable_article_model.dart';
import 'article_firestore_data_source.dart';
import 'publication_data_source_exception.dart';

/// SDK operations kept here so tests can replace I/O without Firebase setup.
abstract class ArticleFirestoreClient {
  String createId(String collection);
  Future<void> setDocument(
      String collection, String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getDocument(
      String collection, String id, GetOptions options);
}

class _FirebaseArticleFirestoreClient implements ArticleFirestoreClient {
  final FirebaseFirestore _firestore;

  _FirebaseArticleFirestoreClient(this._firestore);

  @override
  String createId(String collection) =>
      _firestore.collection(collection).doc().id;

  @override
  Future<void> setDocument(
      String collection, String id, Map<String, dynamic> data) {
    return _firestore.collection(collection).doc(id).set(data);
  }

  @override
  Future<Map<String, dynamic>?> getDocument(
      String collection, String id, GetOptions options) async {
    final snapshot =
        await _firestore.collection(collection).doc(id).get(options);
    return snapshot.exists ? snapshot.data() : null;
  }
}

class FirebaseArticleFirestoreDataSource implements ArticleFirestoreDataSource {
  static const _collection = 'articles';
  final ArticleFirestoreClient _client;

  FirebaseArticleFirestoreDataSource(FirebaseFirestore firestore)
      : _client = _FirebaseArticleFirestoreClient(firestore);

  /// Internal I/O boundary for deterministic data-layer tests.
  FirebaseArticleFirestoreDataSource.withClient(this._client);

  @override
  String createArticleId() {
    try {
      return _client.createId(_collection);
    } on FirebaseException catch (error) {
      // ID allocation is part of creation; no document has been written yet.
      throw _sdkException(error, PublicationDataSourceOperation.createArticle);
    }
  }

  @override
  Future<void> createArticle({
    required String articleId,
    required PublishArticleParams params,
    required String thumbnailUrl,
  }) async {
    try {
      await _client.setDocument(_collection, articleId, {
        'author': params.author,
        'title': params.title,
        'description': params.description,
        'content': params.content,
        'thumbnailURL': thumbnailUrl,
        'publishedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw _sdkException(error, PublicationDataSourceOperation.createArticle);
    }
  }

  @override
  Future<PublishableArticleModel> getArticleById(String articleId) async {
    try {
      final raw = await _client.getDocument(
          _collection, articleId, const GetOptions(source: Source.server));
      if (raw == null) {
        throw const PublicationDataSourceException(
          source: PublicationDataSource.firestore,
          operation: PublicationDataSourceOperation.getArticle,
          code: 'not-found',
          message: 'The article document does not exist.',
        );
      }
      final data = Map<String, dynamic>.from(raw);
      for (final field in ['publishedAt', 'createdAt', 'updatedAt']) {
        final value = data[field];
        if (value is! Timestamp) {
          throw FormatException('Article field "$field" must be a Timestamp.');
        }
        data[field] = value.toDate();
      }
      return PublishableArticleModel.fromRawData(id: articleId, data: data);
    } on FirebaseException catch (error) {
      throw _sdkException(error, PublicationDataSourceOperation.getArticle);
    } on FormatException catch (error) {
      throw PublicationDataSourceException(
        source: PublicationDataSource.firestore,
        operation: PublicationDataSourceOperation.getArticle,
        code: 'invalid-data',
        message: 'The article document contains invalid data.',
        cause: error,
      );
    }
  }

  PublicationDataSourceException _sdkException(
      FirebaseException error, PublicationDataSourceOperation operation) {
    return PublicationDataSourceException(
      source: PublicationDataSource.firestore,
      operation: operation,
      code: error.code,
      message: error.message ?? 'Firestore operation failed.',
      cause: error,
    );
  }
}
