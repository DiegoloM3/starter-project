import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

import 'community_article_remote_datasource.dart';

class CommunityArticleFirestoreDataSource
    implements CommunityArticleRemoteDataSource {
  static const _collection = 'articles';

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CommunityArticleFirestoreDataSource(this._firestore, this._storage);

  CollectionReference<Map<String, dynamic>> get _articlesRef =>
      _firestore.collection(_collection);

  @override
  Stream<List<ArticleEntity>> watchArticles() {
    return _articlesRef
        .orderBy('publishedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_docToEntity).toList());
  }

  @override
  Future<String> uploadArticleImage({
    required String uid,
    required File imageFile,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = imageFile.path.split('/').last;
    final ref = _storage.ref('articles/$uid/${timestamp}_$filename');
    final task = await ref.putFile(imageFile);
    return task.ref.getDownloadURL();
  }

  @override
  Future<void> deleteArticle({
    required String firestoreId,
    String? imageUrl,
  }) async {
    // Delete the Firestore document first. If this fails, the security rule
    // rejected the operation (or the network is down) — propagate the error.
    await _articlesRef.doc(firestoreId).delete();

    // Best-effort image cleanup. A missing file or transient Storage error
    // must NOT roll back the successful doc deletion.
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (_) {
        // Swallowed — orphan logged in improvements.md (IMP-005).
      }
    }
  }

  @override
  Future<String> publishArticle(ArticleEntity article) async {
    final uid = article.uid;
    if (uid == null) {
      throw ArgumentError('uid is required to publish a community article');
    }
    final docRef = await _articlesRef.add({
      'uid': uid,
      'title': article.title,
      'description': article.description,
      'content': article.content,
      'imageUrl': article.urlToImage,
      'publishedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  ArticleEntity _docToEntity(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final ts = data['publishedAt'];
    final publishedAt = ts is Timestamp ? ts.toDate().toIso8601String() : null;
    return ArticleEntity(
      firestoreId: doc.id,
      uid: data['uid'] as String?,
      title: data['title'] as String?,
      description: data['description'] as String?,
      content: data['content'] as String?,
      urlToImage: data['imageUrl'] as String?,
      publishedAt: publishedAt,
    );
  }
}
