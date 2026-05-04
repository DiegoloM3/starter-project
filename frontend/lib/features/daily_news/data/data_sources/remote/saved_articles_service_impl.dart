import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/saved_articles_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class SavedArticlesServiceImpl implements SavedArticlesService {
  final FirebaseFirestore _firestore;

  SavedArticlesServiceImpl(this._firestore);

  // SHA-1 of the URL gives an idempotent, fixed-length doc id (≤40 chars
  // → safe under Firestore's doc-name byte limit even for long URLs).
  static String articleIdFor(ArticleEntity article) {
    final url = article.url ?? '';
    return sha1.convert(utf8.encode(url)).toString();
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('savedArticles');

  @override
  Future<List<ArticleEntity>> getSavedArticles(String uid) async {
    final snapshot =
        await _collection(uid).orderBy('savedAt', descending: true).get();
    return snapshot.docs.map(_fromFirestore).toList();
  }

  @override
  Future<void> saveArticle(String uid, ArticleEntity article) async {
    final id = articleIdFor(article);
    await _collection(uid).doc(id).set({
      'source': 'newsapi',
      'url': article.url ?? '',
      'title': article.title ?? '',
      'description': article.description ?? '',
      'urlToImage': article.urlToImage ?? '',
      'publishedAt': article.publishedAt ?? '',
      'author': article.author ?? '',
      'content': article.content ?? '',
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeArticle(String uid, ArticleEntity article) async {
    final id = articleIdFor(article);
    await _collection(uid).doc(id).delete();
  }

  @override
  Future<bool> isSaved(String uid, ArticleEntity article) async {
    final id = articleIdFor(article);
    final doc = await _collection(uid).doc(id).get();
    return doc.exists;
  }

  ArticleEntity _fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return ArticleEntity(
      author: data['author'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      url: data['url'] as String? ?? '',
      urlToImage: data['urlToImage'] as String? ?? '',
      publishedAt: data['publishedAt'] as String? ?? '',
      content: data['content'] as String? ?? '',
    );
  }
}
