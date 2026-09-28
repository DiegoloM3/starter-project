import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserArticleFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserArticleFirestoreDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  Future<String> uploadThumbnail(File image) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref('media/articles/$fileName');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> saveArticle(Map<String, dynamic> data) {
    return _firestore.collection('articles').add(data);
  }

  Future<List<Map<String, dynamic>>> getArticles() async {
    final snapshot = await _firestore
        .collection('articles')
        .orderBy('publishedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<void> deleteArticle(String id, String thumbnailUrl) async {
    await _firestore.collection('articles').doc(id).delete();
    await _storage.refFromURL(thumbnailUrl).delete();
  }
}