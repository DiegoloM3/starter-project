// coverage:ignore-file
// Thin wrapper over the Cloud Firestore SDK.
// Covered by the repository tests above it, with the SDK mocked at this seam.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/user_article_model.dart';

/// Reads and writes the `articles` collection. Converts Firestore
/// timestamps to [DateTime] on the way in and stamps the server-owned
/// `createdAt` / `updatedAt` on the way out. Errors propagate as
/// [FirebaseException]s.
class ArticleFirestoreService {
  final FirebaseFirestore _firestore;

  ArticleFirestoreService(this._firestore);

  static const String collectionName = 'articles';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';

  CollectionReference<Map<String, dynamic>> get _articles =>
      _firestore.collection(collectionName);

  /// Newest first, capped so the feed never pulls the whole collection.
  Future<List<UserArticleModel>> fetchArticles({int limit = 100}) async {
    final snapshot = await _articles
        .orderBy(UserArticleModel.fieldPublishedAt, descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(_toModel).toList();
  }

  /// One journalist's articles. Sorting happens client-side so no composite
  /// index has to be deployed.
  Future<List<UserArticleModel>> fetchArticlesByAuthor(String authorId) async {
    final snapshot = await _articles.where(UserArticleModel.fieldAuthorId, isEqualTo: authorId).get();
    return snapshot.docs.map(_toModel).toList();
  }

  /// `null` when the document does not exist.
  Future<UserArticleModel?> fetchArticle(String id) async {
    final doc = await _articles.doc(id).get();
    if (!doc.exists) return null;
    return _toModel(doc);
  }

  /// Creates the document and returns its generated id.
  Future<String> createArticle(Map<String, dynamic> data) async {
    final doc = _articles.doc();
    await doc.set({
      ..._toFirestore(data),
      fieldCreatedAt: FieldValue.serverTimestamp(),
      fieldUpdatedAt: FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateArticle(String id, Map<String, dynamic> data) {
    return _articles.doc(id).update({
      ..._toFirestore(data),
      fieldUpdatedAt: FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteArticle(String id) => _articles.doc(id).delete();

  static UserArticleModel _toModel(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return UserArticleModel.fromRawData(doc.id, {
      for (final entry in data.entries)
        entry.key: entry.value is Timestamp ? (entry.value as Timestamp).toDate() : entry.value,
    });
  }

  static Map<String, dynamic> _toFirestore(Map<String, dynamic> data) => {
        for (final entry in data.entries)
          entry.key: entry.value is DateTime ? Timestamp.fromDate(entry.value as DateTime) : entry.value,
      };
}
