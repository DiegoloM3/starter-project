import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/errors/error_keys.dart';
import 'package:news_app_clean_architecture/core/errors/exceptions.dart';

import '../../../data/models/community_article_model.dart';

/// Data source for all community article Firestore operations.
///
/// This is the only class that imports [cloud_firestore] for community articles.
/// All methods throw [ServerException] on failure.
@lazySingleton
class FirestoreArticlesDataSource {
  final FirebaseFirestore _firestore;

  static const String _collection = 'community_articles';

  FirestoreArticlesDataSource(this._firestore);

  /// Watches the newest community articles ordered by newest first.
  Stream<List<CommunityArticleModel>> watchArticles(int pageSize) {
    try {
      return _firestore
          .collection(_collection)
          .orderBy('publishedAt', descending: true)
          .limit(pageSize)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(_modelFromDocument).toList())
          .handleError((Object error) {
            if (error is FirebaseException) {
              throw ServerException(
                message: ServerErrorKeys.generic,
                statusCode: int.tryParse(error.code),
              );
            }
            throw const ServerException(message: ServerErrorKeys.generic);
          });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: ServerErrorKeys.generic,
        statusCode: int.tryParse(e.code),
      );
    }
  }

  /// Fetches a page of community articles ordered by newest first.
  ///
  /// Pass [lastDocumentId] for cursor-based pagination (next page).
  Future<List<CommunityArticleModel>> getArticles(
    int pageSize,
    String? lastDocumentId,
  ) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(_collection)
          .orderBy('publishedAt', descending: true)
          .limit(pageSize);

      if (lastDocumentId != null) {
        final lastDoc = await _firestore
            .collection(_collection)
            .doc(lastDocumentId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs.map(_modelFromDocument).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: ServerErrorKeys.generic,
        statusCode: int.tryParse(e.code),
      );
    }
  }

  /// Fetches a single community article by its Firestore document [id].
  Future<CommunityArticleModel> getArticleById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) {
        throw const ServerException(message: ServerErrorKeys.notFound);
      }
      return _modelFromDocument(doc);
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: ServerErrorKeys.generic,
        statusCode: int.tryParse(e.code),
      );
    }
  }

  /// Fetches all articles authored by [userId], ordered by newest first.
  Future<List<CommunityArticleModel>> getUserArticles(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('authorId', isEqualTo: userId)
          .orderBy('publishedAt', descending: true)
          .get();

      return snapshot.docs.map(_modelFromDocument).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: ServerErrorKeys.generic,
        statusCode: int.tryParse(e.code),
      );
    }
  }

  /// Creates a new community article document and returns the created model.
  Future<CommunityArticleModel> createArticle({
    required String authorId,
    required String authorName,
    required String title,
    required String content,
    String? description,
    String? imageUrl,
    String? category,
  }) async {
    try {
      final now = DateTime.now();
      final data = <String, dynamic>{
        'authorId': authorId,
        'authorName': authorName,
        'title': title,
        'content': content,
        'description': ?description,
        'imageUrl': ?imageUrl,
        'category': ?category,
        'publishedAt': Timestamp.fromDate(now),
      };

      final docRef = await _firestore.collection(_collection).add(data);
      final created = await docRef.get();
      return _modelFromDocument(created);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: ServerErrorKeys.generic,
        statusCode: int.tryParse(e.code),
      );
    }
  }

  /// Updates specified fields of a community article and returns the updated model.
  ///
  /// Only non-null named parameters are written to Firestore.
  /// Set [removeImageUrl] to true to explicitly delete the image field.
  Future<CommunityArticleModel> updateArticle({
    required String id,
    String? title,
    String? content,
    String? description,
    String? imageUrl,
    bool removeImageUrl = false,
    String? category,
  }) async {
    try {
      final updates = <String, dynamic>{
        'title': ?title,
        'content': ?content,
        'description': ?description,
        'category': ?category,
        'imageUrl': ?imageUrl,
        if (removeImageUrl) 'imageUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_collection).doc(id).update(updates);
      final updated = await _firestore.collection(_collection).doc(id).get();
      return _modelFromDocument(updated);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: ServerErrorKeys.generic,
        statusCode: int.tryParse(e.code),
      );
    }
  }

  /// Deletes the community article document with the given [id].
  Future<void> deleteArticle(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: ServerErrorKeys.generic,
        statusCode: int.tryParse(e.code),
      );
    }
  }

  CommunityArticleModel _modelFromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return CommunityArticleModel.fromRawData({
      ...data,
      'id': doc.id,
      'publishedAt': (data['publishedAt'] as Timestamp).toDate(),
      'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
    });
  }
}
