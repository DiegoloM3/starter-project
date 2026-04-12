import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/firestore_article.dart';

class FirestoreArticleService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const _collection = 'articles';
  static const _storagePath = 'media/articles';

  FirestoreArticleService(this._firestore, this._storage);

  Future<List<FirestoreArticleModel>> getArticles() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
      }
      return FirestoreArticleModel.fromRawData(data, doc.id);
    }).toList();
  }

  Future<FirestoreArticleModel> createArticle(
    FirestoreArticleModel model,
    List<File> imageFiles,
  ) async {
    final docRef = _firestore.collection(_collection).doc();
    final imageUrls = await _uploadImages(docRef.id, imageFiles);

    final updatedModel = FirestoreArticleModel(
      documentId: docRef.id,
      title: model.title,
      author: model.author,
      description: model.description,
      content: model.content,
      section: model.section,
      images: imageUrls,
      userId: model.userId,
    );

    final firestoreData = updatedModel.toFirestoreMap();
    firestoreData['createdAt'] = FieldValue.serverTimestamp();

    await docRef.set(firestoreData);

    return updatedModel;
  }

  Future<FirestoreArticleModel> updateArticle(
    FirestoreArticleModel model,
    List<File> newImageFiles,
    List<String> existingImageUrls,
  ) async {
    final documentId = model.documentId;
    if (documentId == null || documentId.isEmpty) {
      throw ArgumentError('documentId is required for update');
    }
    final startIndex = existingImageUrls.length;
    final newUrls = await _uploadImages(documentId, newImageFiles, startIndex);
    final allImageUrls = [...existingImageUrls, ...newUrls];

    final updatedModel = FirestoreArticleModel(
      documentId: documentId,
      title: model.title,
      author: model.author,
      description: model.description,
      content: model.content,
      section: model.section,
      images: allImageUrls,
      userId: model.userId,
      publishedAt: model.publishedAt,
    );

    // Firestore update() only overwrites provided fields, so omitting
    // createdAt preserves it without an extra document read.
    await _firestore
        .collection(_collection)
        .doc(documentId)
        .update(updatedModel.toFirestoreMap());

    return updatedModel;
  }

  Future<void> deleteArticle(String documentId) async {
    if (documentId.isEmpty) {
      throw ArgumentError('documentId cannot be empty');
    }
    await Future.wait([
      _deleteStorageFolder(documentId),
      _firestore.collection(_collection).doc(documentId).delete(),
    ]);
  }

  Future<List<String>> _uploadImages(
    String articleId,
    List<File> files, [
    int startIndex = 0,
  ]) {
    return Future.wait(
      files.asMap().entries.map((entry) async {
        final index = startIndex + entry.key;
        final file = entry.value;
        final ext = file.path.split('.').last;
        final ref = _storage.ref('$_storagePath/$articleId/$index.$ext');
        final bytes = await file.readAsBytes();
        await ref.putData(bytes);
        return ref.getDownloadURL();
      }),
    );
  }

  Future<void> _deleteStorageFolder(String articleId) async {
    final listResult = await _storage.ref('$_storagePath/$articleId').listAll();
    await Future.wait(listResult.items.map((item) => item.delete()));
  }
}
