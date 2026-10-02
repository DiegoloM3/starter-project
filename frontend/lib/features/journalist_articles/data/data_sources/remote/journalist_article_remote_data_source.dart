import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/signed_in_journalist.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/journalist_article.dart';
import 'firestore_paths.dart';

abstract class JournalistArticleRemoteDataSource {
  /// Published articles, newest first, each one with the number of comments it has.
  Future<List<JournalistArticleModel>> getPublishedArticles();

  /// The articles with the given IDs, in the same order, each one with the number of comments it has.
  /// IDs of articles that do not exist are skipped.
  Future<List<JournalistArticleModel>> getArticles(List<String> articleIds);

  /// Generates the ID of a new article without creating it, so its thumbnail can be named after it.
  String generateArticleId();

  /// Creates the article document in the name of the signed-in journalist and returns it as stored,
  /// with the publication date set by the server.
  Future<JournalistArticleModel> createArticle(String articleId, Map<String, dynamic> rawData);
}

/// Throws a [FirebaseException] when Firestore cannot complete a request.
class JournalistArticleRemoteDataSourceImpl implements JournalistArticleRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  JournalistArticleRemoteDataSourceImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _articles => _firestore.collection(FirestorePaths.articles);

  @override
  Future<List<JournalistArticleModel>> getPublishedArticles() async {
    final snapshot = await _articles.orderBy('publishedAt', descending: true).get();
    return Future.wait(snapshot.docs.map(_toModelWithCommentCount));
  }

  @override
  Future<List<JournalistArticleModel>> getArticles(List<String> articleIds) async {
    final snapshots = await Future.wait(articleIds.map((articleId) => _articles.doc(articleId).get()));
    return Future.wait(snapshots.where((snapshot) => snapshot.exists).map(_toModelWithCommentCount));
  }

  @override
  String generateArticleId() => _articles.doc().id;

  @override
  Future<JournalistArticleModel> createArticle(String articleId, Map<String, dynamic> rawData) async {
    final document = _articles.doc(articleId);
    await document.set({
      ...rawData,
      ...readAuthorOfSignedInJournalist(_auth),
      'publishedAt': FieldValue.serverTimestamp(),
    });
    return _toModel(await document.get());
  }

  /// Firestore counts the comments (a count() query) without downloading them.
  Future<JournalistArticleModel> _toModelWithCommentCount(DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    final commentCount = await snapshot.reference.collection(FirestorePaths.comments).count().get();
    return _toModel(snapshot, commentCount: commentCount.count ?? 0);
  }

  JournalistArticleModel _toModel(DocumentSnapshot<Map<String, dynamic>> snapshot, {int commentCount = 0}) {
    final data = snapshot.data()!;
    final publishedAt = (data['publishedAt'] as Timestamp).toDate();
    return JournalistArticleModel.fromRawData(
      snapshot.id,
      {...data, 'publishedAt': publishedAt, 'commentCount': commentCount},
    );
  }
}
