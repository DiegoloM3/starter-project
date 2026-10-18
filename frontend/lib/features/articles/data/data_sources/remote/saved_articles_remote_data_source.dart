import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/resources/exceptions.dart';

/// Saved articles of the signed in user, at `users/{uid}/savedArticles/{articleId}`.
class SavedArticlesRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SavedArticlesRemoteDataSource(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>> get _savedArticles {
    final uid = _auth.currentUser?.uid ?? (throw const NotSignedInException());
    return _firestore.collection('users').doc(uid).collection('savedArticles');
  }

  /// Most recently saved first.
  Future<List<String>> getSavedArticleIds() async {
    final snapshot = await _savedArticles.orderBy('savedAt', descending: true).get();
    return snapshot.docs.map((document) => document.id).toList();
  }

  Future<void> saveArticle(String articleId) {
    return _savedArticles.doc(articleId).set({'savedAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeSavedArticle(String articleId) => _savedArticles.doc(articleId).delete();
}
