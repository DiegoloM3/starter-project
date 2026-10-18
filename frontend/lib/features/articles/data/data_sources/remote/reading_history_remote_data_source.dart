import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/resources/exceptions.dart';

/// Views of the signed in user, at `users/{uid}/history/{articleId}`. The id is the article id,
/// so viewing an article again only updates its date.
class ReadingHistoryRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ReadingHistoryRemoteDataSource(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>> get _history {
    final uid = _auth.currentUser?.uid ?? (throw const NotSignedInException());
    return _firestore.collection('users').doc(uid).collection('history');
  }

  Query<Map<String, dynamic>> get _mostRecentFirst => _history.orderBy('viewedAt', descending: true);

  Future<void> recordView(String articleId) {
    return _history.doc(articleId).set({'viewedAt': FieldValue.serverTimestamp()});
  }

  Future<List<String>> getRecentArticleIds(int count) async {
    final snapshot = await _mostRecentFirst.limit(count).get();
    return snapshot.docs.map((document) => document.id).toList();
  }

  /// Deletes the older views in a single batch.
  Future<void> deleteViewsBeyond(int count) async {
    final olderViews = (await _mostRecentFirst.get()).docs.skip(count);
    if (olderViews.isEmpty) return;
    final batch = _firestore.batch();
    for (final view in olderViews) {
      batch.delete(view.reference);
    }
    await batch.commit();
  }
}
