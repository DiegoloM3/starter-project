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
              return ArticleModel.fromFirestore(_parseTimestamps(data));
            },
            toFirestore: (model, _) =>
                _toFirestorePayload(model.toFirestoreMap()),
          );

  /// Converts Firestore `Timestamp` fields to ISO-8601 strings so the model
  /// layer never depends on cloud_firestore.
  Map<String, dynamic> _parseTimestamps(Map<String, dynamic> data) {
    return {
      ...data,
      'publishedAt': _timestampToIso(data['publishedAt']),
      'createdAt': _timestampToIso(data['createdAt']),
      'updatedAt': _timestampToIso(data['updatedAt']),
    };
  }

  /// Translates the model's plain-Dart payload into Firestore SDK types:
  /// the server-timestamp sentinel becomes `FieldValue.serverTimestamp()` and
  /// ISO-8601 `publishedAt` strings become `Timestamp`s.
  Map<String, dynamic> _toFirestorePayload(Map<String, dynamic> map) {
    final result = <String, dynamic>{...map};
    for (final key in const ['createdAt', 'updatedAt']) {
      if (result[key] == ArticleModel.serverTimestampSentinel) {
        result[key] = FieldValue.serverTimestamp();
      }
    }
    final publishedAt = result['publishedAt'];
    if (publishedAt is String && publishedAt.isNotEmpty) {
      result['publishedAt'] = Timestamp.fromDate(DateTime.parse(publishedAt));
    } else {
      result['publishedAt'] = null;
    }
    return result;
  }

  static String? _timestampToIso(Object? value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is String) return value;
    return null;
  }

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
    // Don't round-trip through get() here: immediately after a write with
    // serverTimestamp, the offline cache resolves createdAt/updatedAt to null.
    // Return the model with locally-known values so the entity's timestamps are
    // never null (the realtime stream later delivers the server-resolved ones).
    final nowIso = DateTime.now().toIso8601String();
    return ArticleModel(
      id: articleWithId.id,
      title: articleWithId.title,
      description: articleWithId.description,
      content: articleWithId.content,
      authorId: articleWithId.authorId,
      authorName: articleWithId.authorName,
      thumbnailUrl: articleWithId.thumbnailUrl,
      thumbnailPath: articleWithId.thumbnailPath,
      url: articleWithId.url,
      publishedAt: articleWithId.publishedAt,
      createdAt: nowIso,
      updatedAt: nowIso,
      status: articleWithId.status,
      isDeleted: articleWithId.isDeleted,
      readingTimeMinutes: articleWithId.readingTimeMinutes,
    );
  }

  Future<ArticleModel> updateArticle(ArticleModel model) async {
    // Use raw reference to avoid withConverter's toFirestore overwriting
    // immutable fields (id, authorId, createdAt).
    await _firestore
        .collection('articles')
        .doc(model.id)
        .update(_toFirestorePayload(model.toFirestoreUpdateMap()));
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
