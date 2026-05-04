import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/remote/articles_firestore_service.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/models/journalist_article_model.dart';

class ArticlesFirestoreServiceImpl implements ArticlesFirestoreService {
  final FirebaseFirestore _firestore;

  ArticlesFirestoreServiceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _articles =>
      _firestore.collection('articles');

  @override
  String allocateArticleId() => _articles.doc().id;

  @override
  Future<void> createArticle(JournalistArticleModel model) async {
    try {
      final map = model.toFirestore();
      map['createdAt'] = FieldValue.serverTimestamp();
      map['updatedAt'] = FieldValue.serverTimestamp();
      map['publishedAt'] = FieldValue.serverTimestamp();
      await _articles.doc(model.id).set(map);
    } on FirebaseException catch (e) {
      throw _mapException(e);
    } catch (e, st) {
      throw FirestoreException(message: e.toString(), cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> updateArticle(
      String articleId, Map<String, dynamic> partial) async {
    try {
      final data = Map<String, dynamic>.from(partial);
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _articles.doc(articleId).update(data);
    } on FirebaseException catch (e) {
      throw _mapException(e);
    } catch (e, st) {
      throw FirestoreException(message: e.toString(), cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> deleteArticle(String articleId) async {
    try {
      await _articles.doc(articleId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _mapException(e);
    } catch (e, st) {
      throw FirestoreException(message: e.toString(), cause: e, stackTrace: st);
    }
  }

  @override
  Stream<JournalistArticleModel?> watchArticleById(String articleId) {
    return _articles.doc(articleId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return JournalistArticleModel.fromRawData(snap);
    });
  }

  @override
  Stream<List<JournalistArticleModel>> watchByAuthor(String userId) {
    return _articles
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((qs) => qs.docs
            .map((d) => JournalistArticleModel.fromRawData(d))
            .toList());
  }

  @override
  Stream<List<JournalistArticleModel>> watchCommunityFeed({int limit = 20}) {
    return _articles
        .where('status', isEqualTo: 'published')
        .where('isDeleted', isEqualTo: false)
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((qs) => qs.docs
            .map((d) => JournalistArticleModel.fromRawData(d))
            .toList());
  }

  @override
  Future<void> toggleFavorite({
    required String articleId,
    required String userId,
    required bool currentlyFavorited,
  }) async {
    try {
      final batch = _firestore.batch();

      final articleFavRef = _articles
          .doc(articleId)
          .collection('favorites')
          .doc(userId);
      final userFavRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(articleId);
      final articleRef = _articles.doc(articleId);

      if (currentlyFavorited) {
        batch.delete(articleFavRef);
        batch.delete(userFavRef);
        batch.update(articleRef,
            {'favoriteCount': FieldValue.increment(-1)});
      } else {
        batch.set(articleFavRef, {
          'userId': userId,
          'articleId': articleId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        batch.set(userFavRef, {'articleId': articleId});
        batch.update(articleRef,
            {'favoriteCount': FieldValue.increment(1)});
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw _mapException(e);
    } catch (e, st) {
      throw FirestoreException(message: e.toString(), cause: e, stackTrace: st);
    }
  }

  @override
  Stream<List<String>> watchFavoriteArticleIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((qs) => qs.docs.map((d) => d.id).toList());
  }

  FirestoreException _mapException(FirebaseException e) {
    return FirestoreException(
      message: e.message ?? e.code,
      code: e.code,
      cause: e,
    );
  }
}
