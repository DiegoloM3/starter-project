import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_file/cross_file.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/article_upload_model.dart';

abstract class ArticleUploadRemoteDataSource {
  Future<ArticleUploadModel> uploadArticle(ArticleUploadModel article);
  Future<String> uploadThumbnail({
    required String localFilePath,
    required String authorId,
  });
  Future<List<ArticleUploadModel>> getMyArticles(String authorId);
  Future<List<ArticleUploadModel>> getAllArticles();
  Future<void> incrementArticleViews(String articleId);
}

class ArticleUploadRemoteDataSourceImpl
    implements ArticleUploadRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ArticleUploadRemoteDataSourceImpl(this._firestore, this._storage);

  @override
  Future<ArticleUploadModel> uploadArticle(ArticleUploadModel article) async {
    final docRef = await _firestore
        .collection('articles')
        .add(article.toFirestore());

    final snapshot = await docRef.get();
    return ArticleUploadModel.fromFirestore(snapshot);
  }

  @override
  Future<String> uploadThumbnail({
    required String localFilePath,
    required String authorId,
  }) async {
    final fileName =
        '${authorId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref('media/articles/$fileName');

    if (kIsWeb) {
      final bytes = await XFile(localFilePath).readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    } else {
      await ref.putFile(File(localFilePath));
    }
    return await ref.getDownloadURL();
  }

  @override
  Future<List<ArticleUploadModel>> getMyArticles(String authorId) async {
    final snapshot = await _firestore
        .collection('articles')
        .where('authorId', isEqualTo: authorId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ArticleUploadModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<ArticleUploadModel>> getAllArticles() async {
    final snapshot = await _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ArticleUploadModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> incrementArticleViews(String articleId) async {
    await _firestore
        .collection('articles')
        .doc(articleId)
        .update({'views': FieldValue.increment(1)});
  }
}
