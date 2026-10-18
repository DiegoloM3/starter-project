import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/resources/exceptions.dart';
import '../../../domain/exceptions/article_exceptions.dart';
import '../../../domain/params/article_draft.dart';
import '../../models/article_model.dart';

/// Articles in Firestore, at `articles/{articleId}`.
class ArticleRemoteDataSource {
  /// Enough for the feed until it is paginated.
  static const int _feedLimit = 50;

  /// Maximum number of values that a Firestore `whereIn` filter accepts.
  static const int _whereInLimit = 30;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ArticleRemoteDataSource(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>> get _articles => _firestore.collection('articles');

  Future<List<ArticleModel>> getArticles() async {
    final snapshot = await _articles.orderBy('publishedAt', descending: true).limit(_feedLimit).get();
    return snapshot.docs.map(_toModel).toList();
  }

  Future<ArticleModel> getArticle(String articleId) async {
    final snapshot = await _articles.doc(articleId).get();
    if (!snapshot.exists) throw ArticleNotFoundException(articleId);
    return _toModel(snapshot);
  }

  /// Newest first, up to the feed limit. Firestore accepts up to 30 authors per query, so the
  /// authors are split into groups and the results are merged.
  Future<List<ArticleModel>> getArticlesByAuthors(List<String> authorIds) async {
    final queries = [
      for (final authorGroup in _groupsForWhereIn(authorIds))
        _articles
            .where('authorId', whereIn: authorGroup)
            .orderBy('publishedAt', descending: true)
            .limit(_feedLimit)
            .get(),
    ];
    final articles =
        (await Future.wait(queries)).expand((snapshot) => snapshot.docs).map(_toModel).toList()
          ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return articles.take(_feedLimit).toList();
  }

  /// Articles that no longer exist are not returned. The order is not guaranteed.
  Future<List<ArticleModel>> getArticlesByIds(List<String> articleIds) async {
    final queries = [
      for (final idGroup in _groupsForWhereIn(articleIds))
        _articles.where(FieldPath.documentId, whereIn: idGroup).get(),
    ];
    final snapshots = await Future.wait(queries);
    return snapshots.expand((snapshot) => snapshot.docs).map(_toModel).toList();
  }

  /// Publishes in the name of the signed in journalist, as the security rules require.
  Future<ArticleModel> createArticle(ArticleDraft draft, String thumbnailURL) async {
    final authorId = _auth.currentUser?.uid ?? (throw const NotSignedInException());
    final article = _articles.doc();
    await article.set({
      ..._editableFields(draft),
      'thumbnailURL': thumbnailURL,
      'publishedAt': FieldValue.serverTimestamp(),
      'authorId': authorId,
      'authorName': await _fullNameOf(authorId),
    });
    return getArticle(article.id);
  }

  Future<ArticleModel> updateArticle(String articleId, ArticleDraft draft, {String? newThumbnailURL}) async {
    await _articles.doc(articleId).update({
      ..._editableFields(draft),
      if (newThumbnailURL != null) 'thumbnailURL': newThumbnailURL,
    });
    return getArticle(articleId);
  }

  Future<void> deleteArticle(String articleId) => _articles.doc(articleId).delete();

  Iterable<List<String>> _groupsForWhereIn(List<String> values) sync* {
    for (var start = 0; start < values.length; start += _whereInLimit) {
      yield values.skip(start).take(_whereInLimit).toList();
    }
  }

  Map<String, Object> _editableFields(ArticleDraft draft) {
    return {
      'title': draft.title,
      'description': draft.description,
      'content': draft.content.deltaJson,
      'topics': draft.topics.map((topic) => topic.id).toList(),
    };
  }

  /// The rules check that the author name matches the profile, so it is read from there.
  Future<String> _fullNameOf(String uid) async {
    final profile = (await _firestore.collection('users').doc(uid).get()).data() ?? const {};
    return '${profile['firstName']} ${profile['lastName']}';
  }

  ArticleModel _toModel(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return ArticleModel.fromRawData(snapshot.id, _withDates(snapshot.data()!));
  }

  /// Converts the Firestore timestamps into Dart dates, so the models do not depend on Firebase.
  Map<String, dynamic> _withDates(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, value is Timestamp ? value.toDate() : value));
  }
}
