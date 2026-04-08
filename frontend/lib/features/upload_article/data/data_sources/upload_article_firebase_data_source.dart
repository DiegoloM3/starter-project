import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/upload_article.dart';

class UploadArticleFirebaseDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  UploadArticleFirebaseDataSource(this._firestore, this._storage, this._auth);

  Future<ArticleEntity> uploadArticle(UploadArticleEntity article) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated before uploading articles');
    }

    final documentRef = _firestore.collection('articles').doc();
    final imageUrl = await _resolveImageUrl(
      rawImageValue: article.urlToImage,
      articleId: documentRef.id,
    );

    final payload = <String, dynamic>{
      'author': article.author,
      'title': article.title,
      'description': article.description,
      'content': article.content,
      'url': article.url,
      'urlToImage': imageUrl,
      'publishedAt': Timestamp.now(),
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'createdBy': currentUser.uid,
      'status': 'published',
      'source': {
        'id': '',
        'name': 'Symmetry Newsroom',
        'type': 'user',
      },
    };

    await documentRef.set(payload);

    return ArticleEntity(
      author: article.author,
      title: article.title,
      description: article.description,
      content: article.content,
      url: article.url,
      urlToImage: imageUrl,
      publishedAt: DateTime.now().toIso8601String(),
    );
  }

  Future<List<ArticleEntity>> getMyUploadedArticles() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated to read uploaded articles');
    }

    final snapshot = await _firestore
        .collection('articles')
        .where('createdBy', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => _mapFirestoreToArticleEntity(doc.data()))
        .toList();
  }

  ArticleEntity _mapFirestoreToArticleEntity(Map<String, dynamic> data) {
    final publishedAt = data['publishedAt'];
    final publishedAtString = publishedAt is Timestamp
        ? publishedAt.toDate().toIso8601String()
        : (publishedAt?.toString() ?? DateTime.now().toIso8601String());

    return ArticleEntity(
      author: data['author']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      url: data['url']?.toString() ?? '',
      urlToImage: data['urlToImage']?.toString() ?? '',
      publishedAt: publishedAtString,
    );
  }

  Future<String> _resolveImageUrl({
    required String rawImageValue,
    required String articleId,
  }) async {
    if (rawImageValue.startsWith('http://') ||
        rawImageValue.startsWith('https://')) {
      return rawImageValue;
    }

    final imageFile = File(rawImageValue);
    if (!imageFile.existsSync()) {
      throw Exception(
        'Image must be a valid URL or an existing local file path',
      );
    }

    final storageRef = _storage.ref().child('media/articles/$articleId.jpg');
    await storageRef.putFile(imageFile);
    return storageRef.getDownloadURL();
  }
}
