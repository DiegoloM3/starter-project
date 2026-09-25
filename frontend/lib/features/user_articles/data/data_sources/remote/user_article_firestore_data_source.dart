import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/models/user_article_model.dart';

/// Only class allowed to import cloud_firestore for this feature
/// (ARCHITECTURE_VIOLATIONS.md Sec. 1.2.3/1.2.4). Converts raw Firestore
/// data to/from UserArticleModel and nothing else -- no business logic here.
/// In particular, this is the only place that knows Firestore Timestamp
/// exists; the model only ever sees plain DateTime.
class UserArticleFirestoreDataSource {
  final FirebaseFirestore _firestore;

  UserArticleFirestoreDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _articles =>
      _firestore.collection('articles');

  /// A doc reference (and its id) generated client-side, no network call --
  /// see backend/docs/DB_SCHEMA.md for why the id must exist before the
  /// thumbnail is uploaded and before the document itself is written.
  DocumentReference<Map<String, dynamic>> newDocumentReference() {
    return _articles.doc();
  }

  UserArticleModel _toModel(String id, Map<String, dynamic> data) {
    final cleaned = Map<String, dynamic>.from(data);
    final createdAt = data['createdAt'];
    final updatedAt = data['updatedAt'];
    if (createdAt is Timestamp) cleaned['createdAt'] = createdAt.toDate();
    if (updatedAt is Timestamp) cleaned['updatedAt'] = updatedAt.toDate();
    return UserArticleModel.fromRawData(id, cleaned);
  }

  /// [authorId]-filtered ("my articles" in DB_SCHEMA.md's query patterns
  /// section) -- this is the query the authorId+createdAt composite index
  /// (firestore.indexes.json) was actually built for. [startAfter] is a
  /// plain DateTime (the last-seen article's createdAt), not a Firestore
  /// DocumentSnapshot, so the pagination cursor never leaks a Firestore SDK
  /// type past this data source.
  Future<List<UserArticleModel>> getArticles({
    required String authorId,
    int limit = 10,
    DateTime? startAfter,
  }) async {
    var query = _articles
        .where('authorId', isEqualTo: authorId)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (startAfter != null) {
      query = query.startAfter([Timestamp.fromDate(startAfter)]);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => _toModel(doc.id, doc.data()))
        .toList();
  }

  /// Every article [authorId] has written, unpaginated: only for deleting
  /// an account, where all of them have to go.
  Future<List<UserArticleModel>> getAllArticles({
    required String authorId,
  }) async {
    final snapshot =
        await _articles.where('authorId', isEqualTo: authorId).get();
    return snapshot.docs.map((doc) => _toModel(doc.id, doc.data())).toList();
  }

  Future<UserArticleModel> getArticleById(String id) async {
    final doc = await _articles.doc(id).get();
    final data = doc.data();
    if (!doc.exists || data == null) {
      throw Exception('Article not found');
    }
    return _toModel(doc.id, data);
  }

  Future<void> createArticle(String id, Map<String, dynamic> data) {
    return _articles.doc(id).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateArticle(String id, Map<String, dynamic> data) {
    return _articles.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteArticle(String id) {
    return _articles.doc(id).delete();
  }

  /// Batched, 500 deletes per commit (Firestore's batch limit), so each
  /// batch either deletes all its articles or none of them.
  Future<void> deleteArticles(List<String> ids) async {
    for (var start = 0; start < ids.length; start += 500) {
      final batch = _firestore.batch();
      for (final id in ids.skip(start).take(500)) {
        batch.delete(_articles.doc(id));
      }
      await batch.commit();
    }
  }
}
