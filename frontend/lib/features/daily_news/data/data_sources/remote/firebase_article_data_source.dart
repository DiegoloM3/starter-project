import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/article.dart';
import '../../../domain/entities/article.dart';

class FirebaseArticleDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseArticleDataSource(this._firestore, this._auth);

  Future<List<ArticleEntity>> getPublishedArticles() async {
    final snapshot = await _firestore
        .collection('articles')
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true)
        .get();

    return snapshot.docs.map(_toEntity).toList();
  }

  Future<void> publishArticle(ArticleEntity article) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('A signed-in user is required to publish an article.');
    }

    final articleReference = _firestore.collection('articles').doc();
    var thumbnailUrl = article.urlToImage ?? '';

    final now = FieldValue.serverTimestamp();
    await articleReference.set({
      'authorId': user.uid,
      'authorName': article.author ?? 'Staff writer',
      'title': article.title ?? '',
      'description': article.description ?? '',
      'content': article.content ?? '',
      'thumbnailURL': thumbnailUrl,
      'createdAt': now,
      'updatedAt': now,
      'publishedAt': now,
      'status': 'published',
    });
  }

  ArticleEntity _toEntity(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    final publishedAt = data['publishedAt'];
    return ArticleModel(
      id: document.id.hashCode,
      author: data['authorName'] as String?,
      title: data['title'] as String?,
      description: data['description'] as String?,
      urlToImage: data['thumbnailURL'] as String?,
      publishedAt: publishedAt is Timestamp ? publishedAt.toDate().toIso8601String() : '',
      content: data['content'] as String?,
    );
  }
}
