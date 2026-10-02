import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/signed_in_journalist.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_comment.dart';
import 'firestore_paths.dart';

abstract class ArticleCommentRemoteDataSource {
  /// Comments of the article [articleId], oldest first.
  Future<List<ArticleCommentModel>> getComments(String articleId);

  /// Creates the comment in the name of the signed-in journalist and returns it as stored,
  /// with the date set by the server.
  Future<ArticleCommentModel> addComment(String articleId, Map<String, dynamic> rawData);
}

/// Throws a [FirebaseException] when Firestore cannot complete a request, and a
/// [NoSignedInJournalistException] when adding a comment while nobody is signed in.
class ArticleCommentRemoteDataSourceImpl implements ArticleCommentRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ArticleCommentRemoteDataSourceImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _commentsOf(String articleId) {
    return _firestore.collection(FirestorePaths.articles).doc(articleId).collection(FirestorePaths.comments);
  }

  @override
  Future<List<ArticleCommentModel>> getComments(String articleId) async {
    final snapshot = await _commentsOf(articleId).orderBy('createdAt').get();
    return snapshot.docs.map(_toModel).toList();
  }

  @override
  Future<ArticleCommentModel> addComment(String articleId, Map<String, dynamic> rawData) async {
    final document = _commentsOf(articleId).doc();
    await document.set({
      ...rawData,
      ...readAuthorOfSignedInJournalist(_auth),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return _toModel(await document.get());
  }

  ArticleCommentModel _toModel(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final createdAt = (data['createdAt'] as Timestamp).toDate();
    return ArticleCommentModel.fromRawData(snapshot.id, {...data, 'createdAt': createdAt});
  }
}
