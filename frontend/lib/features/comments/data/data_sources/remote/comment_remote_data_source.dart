import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/resources/exceptions.dart';
import '../../models/comment_model.dart';

/// Comments in Firestore, at `articles/{articleId}/comments/{commentId}`.
class CommentRemoteDataSource {
  /// Enough for an article until the comments are paginated.
  static const int _commentsLimit = 100;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CommentRemoteDataSource(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>> _commentsOf(String articleId) {
    return _firestore.collection('articles').doc(articleId).collection('comments');
  }

  Future<List<CommentModel>> getComments(String articleId) async {
    final snapshot = await _commentsOf(articleId).orderBy('createdAt', descending: true).limit(_commentsLimit).get();
    return snapshot.docs.map((document) => _toModel(articleId, document)).toList();
  }

  /// Comments in the name of the signed in user, as the security rules require.
  Future<CommentModel> addComment(String articleId, String text) async {
    final authorId = _auth.currentUser?.uid ?? (throw const NotSignedInException());
    final comment = _commentsOf(articleId).doc();
    await comment.set({
      'authorId': authorId,
      'authorName': await _fullNameOf(authorId),
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return _toModel(articleId, await comment.get());
  }

  Future<void> deleteComment(String articleId, String commentId) => _commentsOf(articleId).doc(commentId).delete();

  /// The rules check that the author name matches the profile, so it is read from there.
  Future<String> _fullNameOf(String uid) async {
    final profile = (await _firestore.collection('users').doc(uid).get()).data() ?? const {};
    return '${profile['firstName']} ${profile['lastName']}';
  }

  CommentModel _toModel(String articleId, DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final createdAt = data['createdAt'];
    return CommentModel.fromRawData(snapshot.id, articleId, {
      ...data,
      'createdAt': createdAt is Timestamp ? createdAt.toDate() : null,
    });
  }
}
