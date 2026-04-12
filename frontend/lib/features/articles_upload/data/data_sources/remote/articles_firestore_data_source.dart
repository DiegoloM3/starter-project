import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/models/article_upload_model.dart';

class ArticlesFirestoreDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'articles';
  static const int pageSize = 20;

  ArticlesFirestoreDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _articles =>
      _firestore.collection(_collection);

  Query<Map<String, dynamic>> get _liveQuery => _articles
      .where('deletedAt', isNull: true)
      .orderBy('publishedAt', descending: true);

  Future<List<ArticleUploadModel>> fetchAll() async {
    final snapshot = await _liveQuery.limit(pageSize).get();
    return snapshot.docs.map(ArticleUploadModel.fromFirestore).toList();
  }

  Future<List<ArticleUploadModel>> fetchNextPage(
      DateTime lastPublishedAt) async {
    final snapshot = await _liveQuery
        .startAfter([Timestamp.fromDate(lastPublishedAt)])
        .limit(pageSize)
        .get();
    return snapshot.docs.map(ArticleUploadModel.fromFirestore).toList();
  }

  Future<ArticleUploadModel> fetchById(String id) async {
    final snapshot = await _articles.doc(id).get();
    if (!snapshot.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Article $id does not exist',
      );
    }
    return ArticleUploadModel.fromFirestore(snapshot);
  }

  Future<ArticleUploadModel> create(ArticleUploadModel model) async {
    final docRef = _articles.doc();
    await docRef.set(model.toFirestoreCreate(docRef.id));
    final fresh = await docRef.get();
    return ArticleUploadModel.fromFirestore(fresh);
  }

  Future<ArticleUploadModel> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _articles.doc(id).update(data);
    final fresh = await _articles.doc(id).get();
    return ArticleUploadModel.fromFirestore(fresh);
  }

  Future<void> softDelete(String id) async {
    await _articles.doc(id).update(ArticleUploadModel.softDeletePayload());
  }
}
