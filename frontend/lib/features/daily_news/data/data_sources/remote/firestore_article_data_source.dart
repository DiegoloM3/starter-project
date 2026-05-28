import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';

class FirestoreArticleDataSource {
  final FirebaseFirestore _firestore;

  FirestoreArticleDataSource(this._firestore);

  CollectionReference<ArticleModel> get _articlesRef =>
      _firestore.collection('articles').withConverter<ArticleModel>(
            fromFirestore: (snap, _) {
              final data = snap.data();
              if (data == null) {
                throw FirebaseException(
                  plugin: 'cloud_firestore',
                  code: 'not-found',
                  message: 'Article document data is null',
                );
              }
              return ArticleModel.fromFirestore(data);
            },
            toFirestore: (model, _) => model.toFirestoreMap(),
          );

  Future<ArticleModel> createArticle(ArticleModel model) async {
    final docRef = _articlesRef.doc();
    final articleWithId = ArticleModel(
      id: docRef.id,
      title: model.title,
      description: model.description,
      content: model.content,
      authorId: model.authorId,
      authorName: model.authorName,
      thumbnailUrl: model.thumbnailUrl,
      thumbnailPath: model.thumbnailPath,
      url: model.url,
      publishedAt: model.publishedAt,
      status: model.status ?? ArticleStatus.draft,
      isDeleted: false,
      readingTimeMinutes: model.readingTimeMinutes,
    );
    await docRef.set(articleWithId);
    final snap = await docRef.get();
    final article = snap.data();
    if (article == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Created article not found',
      );
    }
    return article;
  }

  Future<ArticleModel> updateArticle(ArticleModel model) async {
    // Use raw reference to avoid withConverter's toFirestore overwriting
    // immutable fields (id, authorId, createdAt).
    await _firestore
        .collection('articles')
        .doc(model.id)
        .update(model.toFirestoreUpdateMap());
    final snap = await _articlesRef.doc(model.id).get();
    final article = snap.data();
    if (article == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Updated article not found',
      );
    }
    return article;
  }

  Future<void> deleteArticle(String articleId) async {
    await _firestore.collection('articles').doc(articleId).update({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ArticleModel>> getPublishedArticles() {
    return _articlesRef
        .where('isDeleted', isEqualTo: false)
        .where('status', isEqualTo: ArticleStatus.published)
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<ArticleModel>> getUserArticles(String userId) {
    return _articlesRef
        .where('authorId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<ArticleModel>> getDraftArticles(String userId) {
    return _articlesRef
        .where('authorId', isEqualTo: userId)
        .where('status', isEqualTo: ArticleStatus.draft)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<ArticleModel>> searchPublishedArticles(String query) {
    final lowerQuery = query.toLowerCase();
    return _articlesRef
        .where('isDeleted', isEqualTo: false)
        .where('status', isEqualTo: ArticleStatus.published)
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => doc.data())
            .where((article) =>
                (article.title?.toLowerCase().contains(lowerQuery) ?? false) ||
                (article.description?.toLowerCase().contains(lowerQuery) ??
                    false))
            .toList());
  }
}
