import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class ProfileRemoteDataSource {
  Future<List<Map<String, dynamic>>> getSavedArticles(String userId, int limit);
  Future<List<Map<String, dynamic>>> getPublishedArticles(String authorId, int limit);
  Future<void> deleteArticle(String articleId, String userId);
  Future<String> uploadAvatar(File imageFile, String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProfileRemoteDataSourceImpl(this._firestore, this._storage);

  @override
  Future<List<Map<String, dynamic>>> getSavedArticles(
    String userId,
    int limit,
  ) async {
    final savedSnapshot = await _firestore
        .collection('saved_articles')
        .where('user_id', isEqualTo: userId)
        .get();

    final sortedDocs = savedSnapshot.docs.toList()
      ..sort((a, b) {
        final aTs = a.data()['saved_at'];
        final bTs = b.data()['saved_at'];
        if (aTs is Timestamp && bTs is Timestamp) {
          return bTs.compareTo(aTs);
        }
        return 0;
      });

    final articleIds = sortedDocs
        .map((doc) => doc.data()['article_id'] as String?)
        .where((id) => id != null)
        .cast<String>()
        .toSet()
        .take(limit)
        .toList();

    if (articleIds.isEmpty) return [];

    final articleDocs = await Future.wait(
      articleIds.map(
        (id) => _firestore.collection('articles').doc(id).get(),
      ),
    );

    final articles = articleDocs
        .where((doc) => doc.exists)
        .map((doc) {
          final data = doc.data()!;
          data['id'] = doc.id;
          return data;
        })
        .where((data) => data['status'] != 'deleted')
        .toList();

    return Future.wait(articles.map(_enrichWithAuthor));
  }

  Future<Map<String, dynamic>> _enrichWithAuthor(
      Map<String, dynamic> article) async {
    final authorId = article['author_id'] as String? ?? '';
    if (authorId.isEmpty) return article;
    // Skip if author data is already stored in the article document
    final storedName = article['author_name'] as String? ?? '';
    final storedAvatar = article['author_avatar_url'] as String? ?? '';
    if (storedName.isNotEmpty) return article;
    try {
      final userDoc =
          await _firestore.collection('users').doc(authorId).get();
      final data = userDoc.data();
      if (data == null) return article;
      return {
        ...article,
        'author_name': (data['name'] as String?) ?? '',
        'author_avatar_url': (data['avatar_url'] as String?) ?? storedAvatar,
      };
    } catch (_) {
      return article;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPublishedArticles(
    String authorId,
    int limit,
  ) async {
    final snapshot = await _firestore
        .collection('articles')
        .where('author_id', isEqualTo: authorId)
        .get();

    final docs = snapshot.docs
        .where((doc) => doc.data()['status'] == 'published')
        .toList()
      ..sort((a, b) {
        final aTs = a.data()['published_at'];
        final bTs = b.data()['published_at'];
        if (aTs is Timestamp && bTs is Timestamp) {
          return bTs.compareTo(aTs);
        }
        return 0;
      });

    final articles = docs.take(limit).map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    return Future.wait(articles.map(_enrichWithAuthor));
  }

  @override
  Future<void> deleteArticle(String articleId, String userId) async {
    final doc = await _firestore.collection('articles').doc(articleId).get();

    if (!doc.exists) throw Exception('El artículo no existe');

    final authorId = doc.data()?['author_id'];
    if (authorId != userId) throw Exception('No autorizado');

    final savedQuery = await _firestore
        .collection('saved_articles')
        .where('article_id', isEqualTo: articleId)
        .get();

    final batch = _firestore.batch();
    for (final saved in savedQuery.docs) {
      batch.delete(saved.reference);
    }
    batch.delete(_firestore.collection('articles').doc(articleId));
    await batch.commit();
  }

  @override
  Future<String> uploadAvatar(File imageFile, String userId) async {
    final ref = _storage.ref('avatars/$userId.jpg');
    final bytes = await imageFile.readAsBytes();
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await ref.getDownloadURL();
  }
}
