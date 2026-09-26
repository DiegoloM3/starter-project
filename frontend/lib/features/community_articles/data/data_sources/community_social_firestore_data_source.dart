import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../config/firebase_options.dart';
import '../models/article_comment_model.dart';

/// Firestore adapter for article likes and comments.
///
/// The adapter deliberately uses `create`/`delete` for likes rather than
/// `set`/`update`: the UID document is the one-like-per-user invariant and
/// the deployed rules reject updates.
class CommunitySocialFirestoreDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  CommunitySocialFirestoreDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ??
            FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: firebaseFirestoreDatabaseId,
            );

  String? get currentUserId => auth.currentUser?.uid;

  String get currentUserName {
    final user = auth.currentUser;
    final displayName = user?.displayName?.trim() ?? '';
    if (displayName.isEmpty) return 'Community reader';
    return displayName.length > 100
        ? displayName.substring(0, 100)
        : displayName;
  }

  CollectionReference<Map<String, dynamic>> _likes(String articleId) =>
      firestore.collection('articles').doc(articleId).collection('likes');

  CollectionReference<Map<String, dynamic>> _comments(String articleId) =>
      firestore.collection('articles').doc(articleId).collection('comments');

  Stream<Set<String>> watchLikeUserIds(String articleId) => _likes(articleId)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((document) => document.data()['uid'] as String? ?? document.id)
            .where((uid) => uid.isNotEmpty)
            .toSet(),
      );

  Stream<List<ArticleCommentModel>> watchComments(String articleId) =>
      _comments(articleId)
          .orderBy('createdAt', descending: true)
          // Keep this bound aligned with the deployed list rule.
          .limit(100)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map(ArticleCommentModel.fromDocument)
              .toList(growable: false));

  Future<void> setLike(
    String articleId, {
    required bool isLiked,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw StateError('Sign in to like articles.');
    final document = _likes(articleId).doc(user.uid);
    if (isLiked) {
      await document.delete();
      return;
    }
    // Flutter's DocumentReference API has no create-only method. A
    // transaction makes this set create-only: it rechecks the document before
    // writing, and the deployed rules reject updates to an existing like.
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      if (snapshot.exists) {
        throw StateError('This article is already liked.');
      }
      transaction.set(document, {
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> addComment(String articleId, String body) async {
    final user = auth.currentUser;
    if (user == null) throw StateError('Sign in to comment.');
    final trimmed = body.trim();
    if (trimmed.isEmpty || trimmed.length > 1000) {
      throw const FormatException('Comments must contain 1–1000 characters.');
    }
    await _comments(articleId).doc().set({
      'authorUid': user.uid,
      'authorName': currentUserName,
      'body': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteComment(String articleId, String commentId) async {
    final user = auth.currentUser;
    if (user == null) throw StateError('Sign in to delete comments.');
    if (commentId.trim().isEmpty) {
      throw const FormatException('The comment identifier is invalid.');
    }
    await _comments(articleId).doc(commentId).delete();
  }
}
