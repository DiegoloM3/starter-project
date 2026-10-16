import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads and writes the `articles` collection (backend/docs/DB_SCHEMA.md).
class ArticlesFirestoreService {
  static const String articlesCollection = 'articles';
  static const String publishedAtField = 'publishedAt';
  static const int maxArticlesPerRead = 50;

  final FirebaseFirestore _firestore;

  ArticlesFirestoreService(this._firestore);

  CollectionReference<Map<String, dynamic>> get _articles => _firestore.collection(articlesCollection);

  String createArticleId() {
    return _articles.doc().id;
  }

  /// Creates the article with the server time as its publication date.
  Future<void> createArticle(String articleId, Map<String, Object> rawArticle) {
    return _articles.doc(articleId).set({
      ...rawArticle,
      publishedAtField: FieldValue.serverTimestamp(),
    });
  }

  /// Returns the newest articles as raw data, with the publication date
  /// converted to a [DateTime].
  Future<List<Map<String, dynamic>>> getLatestArticles() async {
    final snapshot = await _articles
        .orderBy(publishedAtField, descending: true)
        .limit(maxArticlesPerRead)
        .get();
    return snapshot.docs.map((document) => _convertToRawData(document.data())).toList();
  }

  Map<String, dynamic> _convertToRawData(Map<String, dynamic> document) {
    final publishedAt = document[publishedAtField] as Timestamp;
    return {...document, publishedAtField: publishedAt.toDate()};
  }
}
