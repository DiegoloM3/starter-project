import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';

import '../../../domain/entities/article_status.dart';
import '../../models/journalist_article_model.dart';

/// The only class in the app that talks to the `articles` collection.
///
/// It is also the only one that knows Firestore's own types exist: documents
/// arrive as snapshots and dates as [Timestamp]s, and both are translated
/// here so that the model above deals in plain Dart (rules 1.2.2 and 1.2.4).
///
/// Errors leave as [RemoteException] carrying Firestore's code, so the
/// repository can recognise a failure without importing Firestore itself.
class FirestoreArticleService {
  final FirebaseFirestore _firestore;

  const FirestoreArticleService(this._firestore);

  CollectionReference<Map<String, dynamic>> get _articles =>
      _firestore.collection(kArticlesCollection);

  /// Runs [operation] under a deadline and rewrites Firestore's exception as
  /// the data layer's own, so that the SDK's types stop at this class.
  ///
  /// The deadline is not belt and braces. Firestore answers a write made
  /// offline by queueing it and leaving the future pending until a server
  /// acknowledges it, which can be never; every caller above would rather
  /// hear "we could not reach the server" than wait forever for an answer
  /// that is not coming.
  Future<T> _translatingErrors<T>(Future<T> Function() operation) async {
    try {
      return await operation().timeout(kFirestoreTimeout);
    } on TimeoutException catch (error) {
      throw RemoteException(
        RemoteException.unavailableCode,
        message: 'Firestore did not answer within $kFirestoreTimeout.',
        cause: error,
      );
    } on FirebaseException catch (error) {
      throw RemoteException(
        error.code,
        message: error.message,
        cause: error,
      );
    }
  }

  /// A stored document as the model expects it: its id, and a body whose
  /// [Timestamp]s have become [DateTime]s.
  static JournalistArticleModel _modelOf(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return JournalistArticleModel.fromRawData(
      snapshot.id,
      _datesToDart(snapshot.data() ?? const <String, dynamic>{}),
    );
  }

  static Map<String, dynamic> _datesToDart(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(
          key,
          value is Timestamp ? value.toDate() : value,
        ));
  }

  static Map<String, dynamic> _datesToTimestamps(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(
          key,
          value is DateTime ? Timestamp.fromDate(value) : value,
        ));
  }

  /// Articles owned by [userId], most recently edited first.
  ///
  /// [searchQuery] is applied in memory, on the author's own articles only.
  /// Firestore has no substring search, and the alternatives (a search
  /// service, or denormalised keyword arrays) are not worth it for a list one
  /// person owns.
  Future<List<JournalistArticleModel>> getUserArticles({
    required String userId,
    ArticleStatus? status,
    String? searchQuery,
  }) {
    return _translatingErrors(() async {
      Query<Map<String, dynamic>> query =
          _articles.where('userId', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      final snapshot = await query.orderBy('updatedAt', descending: true).get();
      final articles = snapshot.docs.map(_modelOf).toList();

      return _applySearchQuery(articles, searchQuery);
    });
  }

  Future<JournalistArticleModel?> getArticleById(String articleId) {
    return _translatingErrors(() async {
      final snapshot = await _articles.doc(articleId).get();

      return snapshot.exists ? _modelOf(snapshot) : null;
    });
  }

  /// Published articles, most recently published first.
  ///
  /// The query always filters by `status`, which is what lets an unauthenticated
  /// reader run it at all: `firestore.rules` rejects a `list` whose filters do
  /// not guarantee every result is readable.
  Future<List<JournalistArticleModel>> getPublishedArticles({
    int limit = 10,
    String? authorId,
    String? excludeArticleId,
    String? startAfterArticleId,
    DateTime? publishedAfter,
  }) {
    return _translatingErrors(() async {
      final query = await _publishedArticlesQuery(
        authorId: authorId,
        startAfterArticleId: startAfterArticleId,
        publishedAfter: publishedAfter,
      );

      // Firestore cannot express "everything except this document" alongside
      // the other filters without extra index constraints, so one extra row is
      // fetched and the excluded one is dropped here.
      final snapshot =
          await query.limit(excludeArticleId == null ? limit : limit + 1).get();

      return snapshot.docs
          .map(_modelOf)
          .where((article) => article.id != excludeArticleId)
          .take(limit)
          .toList();
    });
  }

  /// Builds the ordered, filtered query the public feed runs.
  ///
  /// It is separate from fetching so that the filtering rules stay readable:
  /// each `if` below is one constraint Firestore has to be told about.
  Future<Query<Map<String, dynamic>>> _publishedArticlesQuery({
    String? authorId,
    String? startAfterArticleId,
    DateTime? publishedAfter,
  }) async {
    Query<Map<String, dynamic>> query = _articles.where(
      'status',
      isEqualTo: ArticleStatus.published.value,
    );

    if (authorId != null) {
      query = query.where('userId', isEqualTo: authorId);
    }

    // Firestore only allows a range filter on the field the results are
    // ordered by first, which is exactly `publishedAt` here. The composite
    // indexes already deployed for the feed cover this query unchanged.
    if (publishedAfter != null) {
      query = query.where(
        'publishedAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(publishedAfter),
      );
    }

    query = query.orderBy('publishedAt', descending: true);

    if (startAfterArticleId == null) {
      return query;
    }

    final cursor = await _articles.doc(startAfterArticleId).get();

    return cursor.exists ? query.startAfterDocument(cursor) : query;
  }

  /// Writes a new document and returns it as stored, so the caller gets the
  /// id Firestore generated.
  Future<JournalistArticleModel> createArticle(
    JournalistArticleModel article,
  ) {
    return _translatingErrors(() async {
      final reference = await _articles.add(
        _datesToTimestamps(article.toRawData()),
      );

      return _modelOf(await reference.get());
    });
  }

  Future<JournalistArticleModel> updateArticle(
    JournalistArticleModel article,
  ) {
    return _translatingErrors(() async {
      final reference = _articles.doc(article.id);

      await reference.update(_datesToTimestamps(article.toRawDataForUpdate()));

      return _modelOf(await reference.get());
    });
  }

  /// Writes [authorName] onto every article owned by [userId], and answers
  /// how many documents it changed.
  ///
  /// One batch rather than a write per article: the rename either lands on
  /// the whole back catalogue or on none of it, so readers never meet two
  /// names for the same person. Articles that already carry the name are left
  /// out, which keeps a second rename to the same value free.
  ///
  /// Only `author` is sent. An update writes just the keys it names, so
  /// `updatedAt`, `publishedAt` and `viewCount` are untouched — which is both
  /// what the operation means and what `firestore.rules` demands of an owner
  /// edit.
  Future<int> updateAuthorName({
    required String userId,
    required String authorName,
  }) {
    return _translatingErrors(() async {
      final stale = await _articlesNotYetSignedBy(userId, authorName);

      if (stale.isEmpty) {
        return 0;
      }

      await _writeAuthorName(authorName, onto: stale);

      return stale.length;
    });
  }

  /// The journalist's articles that do not already carry [authorName].
  ///
  /// Leaving out the ones that do keeps a repeated rename to the same value
  /// free, and keeps the batch below to the documents it has to touch.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _articlesNotYetSignedBy(String userId, String authorName) async {
    final snapshot = await _articles.where('userId', isEqualTo: userId).get();

    return snapshot.docs
        .where((document) => document.data()['author'] != authorName)
        .toList();
  }

  /// Signs [documents] with [authorName], all of them or none.
  Future<void> _writeAuthorName(
    String authorName, {
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> onto,
  }) {
    final batch = _firestore.batch();

    for (final document in onto) {
      batch.update(document.reference, <String, dynamic>{
        'author': authorName,
      });
    }

    return batch.commit();
  }

  Future<void> deleteArticle(String articleId) {
    return _translatingErrors(() => _articles.doc(articleId).delete());
  }

  /// Raises the article's view count by one.
  ///
  /// [FieldValue.increment] keeps this correct when several readers open the
  /// same article at once, and it is the only shape `firestore.rules` accepts
  /// from somebody who is not the author.
  Future<void> incrementViewCount(String articleId) {
    return _translatingErrors(
      () => _articles.doc(articleId).update({
        'viewCount': FieldValue.increment(1),
      }),
    );
  }

  List<JournalistArticleModel> _applySearchQuery(
    List<JournalistArticleModel> articles,
    String? searchQuery,
  ) {
    if (searchQuery == null || searchQuery.trim().isEmpty) {
      return articles;
    }

    final query = searchQuery.trim();

    return articles.where((article) => article.matches(query)).toList();
  }
}
