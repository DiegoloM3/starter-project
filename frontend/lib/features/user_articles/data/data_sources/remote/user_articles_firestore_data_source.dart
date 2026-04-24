import 'package:cloud_firestore/cloud_firestore.dart';

/// Thin adapter over the `articles` collection.
///
/// Talks Firestore primitives only — no domain failure mapping, no
/// entities. Throws `FirebaseException` on failure so the repository can
/// translate it into the domain failure hierarchy.
class UserArticlesFirestoreDataSource {
  UserArticlesFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  static const _collection = 'articles';

  /// Generates a fresh document id without writing anything. Used by the
  /// repository so thumbnail uploads and Firestore creates share the same
  /// id (required by `storage.rules` and `firestore.rules#isValidArticle`).
  String reserveId() => _firestore.collection(_collection).doc().id;

  Future<List<Map<String, dynamic>>> getMyArticles(String authorId) async {
    final query = await _firestore
        .collection(_collection)
        .where('authorId', isEqualTo: authorId)
        .orderBy('updatedAt', descending: true)
        .get();
    return query.docs.map((doc) => doc.data()).toList();
  }

  Future<Map<String, dynamic>> getArticle(String id) async {
    final snap = await _firestore.collection(_collection).doc(id).get();
    if (!snap.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Article $id not found',
      );
    }
    return snap.data()!;
  }

  /// Creates the document and stamps `publishedAt`/`updatedAt` with the
  /// server clock so the rules check (`data.publishedAt == request.time`)
  /// passes deterministically.
  Future<Map<String, dynamic>> createArticle(
    Map<String, dynamic> payload,
  ) async {
    final id = payload['id'] as String;
    final docRef = _firestore.collection(_collection).doc(id);
    await docRef.set({
      ...payload,
      'publishedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final snap = await docRef.get();
    return snap.data()!;
  }

  Future<Map<String, dynamic>> updateArticle(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final docRef = _firestore.collection(_collection).doc(id);
    await docRef.update({
      ...payload,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final snap = await docRef.get();
    return snap.data()!;
  }

  Future<void> deleteArticle(String id) {
    return _firestore.collection(_collection).doc(id).delete();
  }
}
