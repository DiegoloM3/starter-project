import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/comment.dart';

class FirestoreCommentDataSource {
  final FirebaseFirestore _firestore;

  FirestoreCommentDataSource(this._firestore);

  CollectionReference<CommentModel> _commentsRef(String articleId) =>
      _firestore
          .collection('articles')
          .doc(articleId)
          .collection('comments')
          .withConverter<CommentModel>(
            fromFirestore: (snap, _) =>
                CommentModel.fromFirestore(snap.data()!),
            toFirestore: (model, _) => model.toFirestoreMap(),
          );

  Future<CommentModel> addComment(CommentModel model) async {
    final ref = _commentsRef(model.articleId!);
    final docRef = ref.doc();
    final commentWithId = CommentModel(
      id: docRef.id,
      articleId: model.articleId,
      authorId: model.authorId,
      authorName: model.authorName,
      content: model.content,
      isDeleted: false,
    );
    await docRef.set(commentWithId);
    final snap = await docRef.get();
    return snap.data()!;
  }

  Stream<List<CommentModel>> getComments(String articleId) {
    return _commentsRef(articleId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  Future<void> deleteComment({
    required String articleId,
    required String commentId,
  }) async {
    await _firestore
        .collection('articles')
        .doc(articleId)
        .collection('comments')
        .doc(commentId)
        .update({'isDeleted': true});
  }
}
