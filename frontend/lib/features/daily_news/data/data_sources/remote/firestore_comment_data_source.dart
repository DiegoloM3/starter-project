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
            fromFirestore: (snap, _) {
              final data = snap.data();
              if (data == null) {
                throw FirebaseException(
                  plugin: 'cloud_firestore',
                  code: 'not-found',
                  message: 'Comment document data is null',
                );
              }
              return CommentModel.fromFirestore(_parseTimestamps(data));
            },
            toFirestore: (model, _) =>
                _toFirestorePayload(model.toFirestoreMap()),
          );

  /// Converts the Firestore `createdAt` `Timestamp` to an ISO-8601 string so the
  /// model layer never depends on cloud_firestore.
  Map<String, dynamic> _parseTimestamps(Map<String, dynamic> data) {
    return {
      ...data,
      'createdAt': _timestampToIso(data['createdAt']),
    };
  }

  /// Translates the model's plain-Dart payload into Firestore SDK types: the
  /// server-timestamp sentinel becomes `FieldValue.serverTimestamp()`.
  Map<String, dynamic> _toFirestorePayload(Map<String, dynamic> map) {
    final result = <String, dynamic>{...map};
    if (result['createdAt'] == CommentModel.serverTimestampSentinel) {
      result['createdAt'] = FieldValue.serverTimestamp();
    }
    return result;
  }

  static String? _timestampToIso(Object? value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is String) return value;
    return null;
  }

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
    // Don't round-trip through get() here: immediately after a write with
    // serverTimestamp, the offline cache resolves createdAt to null. Return the
    // model with a locally-known timestamp so the entity's createdAt is never
    // null (the realtime stream later delivers the server-resolved value).
    return CommentModel(
      id: commentWithId.id,
      articleId: commentWithId.articleId,
      authorId: commentWithId.authorId,
      authorName: commentWithId.authorName,
      content: commentWithId.content,
      createdAt: DateTime.now().toIso8601String(),
      isDeleted: commentWithId.isDeleted,
    );
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
