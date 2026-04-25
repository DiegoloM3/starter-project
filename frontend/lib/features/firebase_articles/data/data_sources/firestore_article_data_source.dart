import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/data/models/firebase_article_model.dart';

class FirestoreArticleDataSource {
  final FirebaseFirestore _firestore;

  FirestoreArticleDataSource(this._firestore);

  Future<List<FirebaseArticleModel>> getArticles() async {
    final snapshot = await _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FirebaseArticleModel.fromFirestore(doc))
        .toList();
  }

  Future<String> createArticle(Map<String, dynamic> data) async {
    final docRef = await _firestore.collection('articles').add(data);
    return docRef.id;
  }

  Future<void> deleteArticle(String articleId) async {
    await _firestore.collection('articles').doc(articleId).delete();
  }
}
