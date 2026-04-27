import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/articles/data/models/article_model.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';

abstract class ArticleRemoteDataSource {
  Future<List<ArticleModel>> getArticles({String? category});

  Future<List<ArticleModel>> getMyArticles(
    String authorId, {
    String? status,
  });

  Future<ArticleModel> getArticleById(String id);

  Future<ArticleModel> createArticle(
    ArticleEntity article, {
    File? thumbnail,
  });

  Future<ArticleModel> updateArticle(
    ArticleEntity article, {
    File? thumbnail,
  });

  Future<void> deleteArticle(String id);
}

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  static const _collection = 'articles';

  ArticleRemoteDataSourceImpl(this._firestore, this._storage, this._auth);

  @override
  Future<List<ArticleModel>> getArticles({String? category}) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ArticleModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<ArticleModel>> getMyArticles(
    String authorId, {
    String? status,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    Query<Map<String, dynamic>> query = _firestore
        .collection(_collection)
        .where('authorId', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ArticleModel.fromFirestore(doc)).toList();
  }

  @override
  Future<ArticleModel> getArticleById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) throw Exception('Article not found: $id');
    return ArticleModel.fromFirestore(doc);
  }

  @override
  Future<ArticleModel> createArticle(
    ArticleEntity article, {
    File? thumbnail,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final docRef = _firestore.collection(_collection).doc();
    String? thumbnailURL;

    if (thumbnail != null) {
      thumbnailURL = await _uploadThumbnail(docRef.id, thumbnail);
    }

    // Build model with uid as authorId. excerpt and readTime are
    // derived from body inside toFirestore() — no duplication here.
    final model = ArticleModel(
      id: docRef.id,
      title: article.title,
      excerpt: '',
      body: article.body,
      category: article.category,
      thumbnailURL: thumbnailURL,
      authorId: uid,
      authorName: article.authorName,
      authorPhotoURL: article.authorPhotoURL,
      readTime: 0,
      status: article.status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(model.toFirestore());

    // Read back from Firestore to get server-resolved timestamps and values.
    final doc = await docRef.get();
    return ArticleModel.fromFirestore(doc);
  }

  @override
  Future<ArticleModel> updateArticle(
    ArticleEntity article, {
    File? thumbnail,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    String? thumbnailURL = article.thumbnailURL;
    if (thumbnail != null) {
      thumbnailURL = await _uploadThumbnail(article.id, thumbnail);
    }

    // Build a temporary model solely to delegate excerpt/readTime
    // computation to toFirestore(), then strip createdAt so we don't
    // overwrite the original creation timestamp.
    final model = ArticleModel(
      id: article.id,
      title: article.title,
      excerpt: '',
      body: article.body,
      category: article.category,
      thumbnailURL: thumbnailURL,
      authorId: uid,
      authorName: article.authorName,
      authorPhotoURL: article.authorPhotoURL,
      readTime: 0,
      status: article.status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final updateMap = Map<String, dynamic>.from(model.toFirestore())
      ..remove('createdAt');

    await _firestore.collection(_collection).doc(article.id).update(updateMap);

    final doc = await _firestore.collection(_collection).doc(article.id).get();
    return ArticleModel.fromFirestore(doc);
  }

  @override
  Future<void> deleteArticle(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return;

    final thumbnailURL = doc.data()?['thumbnailURL'] as String?;

    // Delete Storage thumbnail first (best-effort — failure is non-fatal).
    if (thumbnailURL != null) {
      try {
        await _storage.refFromURL(thumbnailURL).delete();
      } catch (_) {
        // Storage deletion failure does not prevent Firestore deletion.
      }
    }

    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<String> _uploadThumbnail(String articleId, File file) async {
    final ref = _storage.ref('media/articles/$articleId');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
