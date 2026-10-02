import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/signed_in_journalist.dart';
import 'firestore_paths.dart';

abstract class SavedJournalistArticleRemoteDataSource {
  /// IDs of the articles the signed-in journalist saved, the last saved first.
  Future<List<String>> getSavedArticleIds();

  Future<bool> isArticleSaved(String articleId);

  Future<void> saveArticle(String articleId);

  Future<void> removeSavedArticle(String articleId);
}

/// Keeps the list in the journalist's account: `users/{userId}/savedArticles/{articleId}` (backend/docs/DB_SCHEMA.md).
/// Throws a [FirebaseException] when Firestore cannot complete a request, and a [NoSignedInJournalistException]
/// when nobody is signed in.
class SavedJournalistArticleRemoteDataSourceImpl implements SavedJournalistArticleRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SavedJournalistArticleRemoteDataSourceImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _savedArticles {
    return _firestore.collection(FirestorePaths.users).doc(readSignedInJournalistId(_auth)).collection(FirestorePaths.savedArticles);
  }

  @override
  Future<List<String>> getSavedArticleIds() async {
    final snapshot = await _savedArticles.orderBy('savedAt', descending: true).get();
    return snapshot.docs.map((document) => document.id).toList();
  }

  @override
  Future<bool> isArticleSaved(String articleId) async {
    final document = await _savedArticles.doc(articleId).get();
    return document.exists;
  }

  @override
  Future<void> saveArticle(String articleId) {
    return _savedArticles.doc(articleId).set({'savedAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> removeSavedArticle(String articleId) => _savedArticles.doc(articleId).delete();
}
