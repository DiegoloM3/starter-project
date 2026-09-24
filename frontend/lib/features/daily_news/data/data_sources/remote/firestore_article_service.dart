import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

abstract class FirestoreArticleService {
  Future<String> uploadArticle(ArticleModel article);
  Future<ArticleModel> updateArticle(String articleId, ArticleModel article);
  Future<void> deleteArticle(String articleId);
  Future<ArticleModel> getArticle(String articleId);
  Future<List<ArticleModel>> getUserArticles(
    String userId, {
    int limit = 10,
    String? cursor,
  });
  Future<void> updatePublishStatus(String articleId, bool isPublished);
}

class FirestoreArticleServiceImpl implements FirestoreArticleService {
  final FirebaseFirestore _firestore;
  static const String _articlesCollection = 'articles';

  FirestoreArticleServiceImpl(this._firestore);

  @override
  Future<String> uploadArticle(ArticleModel article) async {
    try {
      final docRef = await _firestore
          .collection(_articlesCollection)
          .add(article.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Failed to upload article: ${e.message}');
    }
  }

  @override
  Future<ArticleModel> updateArticle(
    String articleId,
    ArticleModel article,
  ) async {
    try {
      await _firestore
          .collection(_articlesCollection)
          .doc(articleId)
          .update(article.toMap());
      return article;
    } on FirebaseException catch (e) {
      throw Exception('Failed to update article: ${e.message}');
    }
  }

  @override
  Future<void> deleteArticle(String articleId) async {
    try {
      await _firestore
          .collection(_articlesCollection)
          .doc(articleId)
          .delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete article: ${e.message}');
    }
  }

  @override
  Future<ArticleModel> getArticle(String articleId) async {
    try {
      final doc = await _firestore
          .collection(_articlesCollection)
          .doc(articleId)
          .get();

      if (!doc.exists) {
        throw Exception('Article not found');
      }

      return ArticleModel.fromMap(doc.data() as Map<String, dynamic>);
    } on FirebaseException catch (e) {
      throw Exception('Failed to get article: ${e.message}');
    }
  }

  @override
  Future<List<ArticleModel>> getUserArticles(
    String userId, {
    int limit = 10,
    String? cursor,
  }) async {
    try {
      Query query = _firestore
          .collection(_articlesCollection)
          .where('uploadedBy', isEqualTo: userId)
          .orderBy('uploadedAt', descending: true)
          .limit(limit);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => ArticleModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get user articles: ${e.message}');
    }
  }

  @override
  Future<void> updatePublishStatus(String articleId, bool isPublished) async {
    try {
      await _firestore
          .collection(_articlesCollection)
          .doc(articleId)
          .update({'isPublished': isPublished});
    } on FirebaseException catch (e) {
      throw Exception('Failed to update publish status: ${e.message}');
    }
  }
}
