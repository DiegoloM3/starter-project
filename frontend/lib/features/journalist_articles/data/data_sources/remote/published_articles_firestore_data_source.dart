import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/published_article.dart';

/// `articles` collection in Cloud Firestore (see backend/docs/DB_SCHEMA.md).
class PublishedArticlesFirestoreDataSource {
  static const String _collectionPath = 'articles';
  static const Duration _writeTimeout = Duration(seconds: 20);

  final FirebaseFirestore _firestore;

  PublishedArticlesFirestoreDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _articles => _firestore.collection(_collectionPath);

  /// A new auto-generated document id. Generated locally, without a network request.
  String newArticleId() => _articles.doc().id;

  /// Stores the article with the server time as `publishedAt`.
  ///
  /// Runs as a transaction on purpose: a plain write made offline is queued and sent later,
  /// after the repository has already given up and removed the thumbnail. A transaction needs
  /// the server, so it fails instead of publishing an article without its image.
  Future<void> createArticle(String articleId, Map<String, Object> fields) {
    final article = _articles.doc(articleId);
    final document = {...fields, PublishedArticleModel.publishedAtField: FieldValue.serverTimestamp()};
    return _firestore.runTransaction((transaction) async {
      transaction.set(article, document);
    }).timeout(_writeTimeout);
  }

  /// Newest articles first. The backend rules only accept list queries with a limit of up to 50.
  Future<List<PublishedArticleModel>> getArticles({required int limit, String? startAfterArticleId}) async {
    var query = _articles.orderBy(PublishedArticleModel.publishedAtField, descending: true).limit(limit);
    if (startAfterArticleId != null) {
      query = query.startAfterDocument(await _articles.doc(startAfterArticleId).get());
    }
    final snapshot = await query.get();
    return snapshot.docs.map(_toModel).toList();
  }

  PublishedArticleModel _toModel(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return PublishedArticleModel.fromRawData({
      ...data,
      PublishedArticleModel.idKey: document.id,
      PublishedArticleModel.publishedAtField: _toDateTime(data[PublishedArticleModel.publishedAtField]),
    });
  }

  // Always UTC, so dates compare equal whatever the device time zone. The UI converts to local time.
  Object? _toDateTime(Object? value) => value is Timestamp ? value.toDate().toUtc() : value;
}
