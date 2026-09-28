import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/comments/data/models/comment.model.dart';

/// Firestore data source for comments in the `comments` collection.
@injectable
class CommentFirebaseService {
  static final _log = Logger('CommentFirebaseService');

  final FirebaseFirestore _firestoreDb = FirebaseFirestore.instance;

  static const String _commentsCollection = kCommentsCollection;

  /// Returns every comment for [articleId], oldest first by `createdAt`.
  /// Reads are public, so no login is required to call this. Returns an
  /// empty list when [articleId] is blank instead of querying.
  Future<List<CommentModel>> getArticleComments(String articleId) async {
    if (articleId.trim().isEmpty) return [];

    _log.info('getArticleComments → querying comments for $articleId');
    final snapshot = await _firestoreDb
        .collection(_commentsCollection)
        .where('articleId', isEqualTo: articleId)
        .orderBy('createdAt')
        .get();

    final comments =
        snapshot.docs.map((doc) => CommentModel.fromJson(doc.data())).toList();
    _log.info('getArticleComments → found ${comments.length} comments');
    return comments;
  }

  /// Saves [comment] to Firestore and mirrors the generated document id
  /// back into its `id` field, following the articles convention.
  Future<void> createComment(CommentModel comment) async {
    _log.info(
      'createComment → saving comment for article ${comment.articleId}',
    );
    final ref = await _firestoreDb
        .collection(_commentsCollection)
        .add(comment.toJson());

    await _firestoreDb
        .collection(_commentsCollection)
        .doc(ref.id)
        .update({'id': ref.id});

    _log.info('createComment → saved with id=${ref.id}');
  }

  /// Deletes the Firestore document with [commentId].
  /// Throws [StateError] when [commentId] is blank.
  Future<void> deleteComment(String commentId) async {
    if (commentId.trim().isEmpty) {
      throw StateError('Cannot delete a comment without an id.');
    }
    _log.info('deleteComment → deleting comment $commentId');
    await _firestoreDb.collection(_commentsCollection).doc(commentId).delete();
    _log.info('deleteComment → deleted comment $commentId');
  }
}
