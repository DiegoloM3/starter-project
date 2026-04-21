import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/comments/data/models/comment_model.dart';
import 'package:news_app_clean_architecture/features/comments/domain/exceptions/comment_exceptions.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/params/add_comment_params.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/params/delete_comment_params.dart';

class FirestoreCommentDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreCommentDataSource(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>> _collectionFor(String articleId) =>
      _firestore.collection('articles').doc(articleId).collection('comments');

  Future<CommentModel> create(AddCommentParams params) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const CommentFailedException('You must be signed in to comment.');
    }
    try {
      final model = CommentModel(
        articleId: params.articleId,
        authorId: user.uid,
        authorName: user.displayName,
        authorPhotoUrl: user.photoURL,
        text: params.text,
        createdAt: DateTime.now(),
        replyTo: params.replyTo,
        isDeleted: false,
      );
      await _collectionFor(params.articleId).add({
        ...model.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return model;
    } on FirebaseException catch (e) {
      throw CommentFailedException(e.message ?? e.code);
    }
  }

  Future<void> markDeleted(DeleteCommentParams params) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const CommentFailedException('You must be signed in to delete.');
    }
    try {
      await _collectionFor(params.articleId).doc(params.commentId).update({
        'text': '',
        'isDeleted': true,
      });
    } on FirebaseException catch (e) {
      throw CommentFailedException(e.message ?? e.code);
    }
  }

  Stream<List<CommentModel>> watch(String articleId) {
    return _collectionFor(articleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _toModel(articleId, d)).toList());
  }

  CommentModel _toModel(
      String articleId, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final raw = doc.data();
    final created = raw['createdAt'];
    return CommentModel.fromRawData(
      articleId: articleId,
      id: doc.id,
      data: {
        ...raw,
        'createdAt': created is Timestamp ? created.toDate() : null,
      },
    );
  }
}
