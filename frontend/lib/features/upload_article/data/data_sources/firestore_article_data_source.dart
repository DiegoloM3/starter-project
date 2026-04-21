import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/upload_article/data/models/user_article_model.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/exceptions/upload_article_exceptions.dart';

class ArticleCreateRequest {
  final String id;
  final String title;
  final String description;
  final String content;
  final String thumbnailUrl;
  final String thumbnailPath;

  const ArticleCreateRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.thumbnailUrl,
    required this.thumbnailPath,
  });
}

class ArticleUpdateRequest {
  final String articleId;
  final String title;
  final String description;
  final String content;
  final String? newThumbnailUrl;
  final String? newThumbnailPath;

  const ArticleUpdateRequest({
    required this.articleId,
    required this.title,
    required this.description,
    required this.content,
    this.newThumbnailUrl,
    this.newThumbnailPath,
  });
}

class FirestoreArticleDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreArticleDataSource(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>> get _articles =>
      _firestore.collection('articles');

  String newArticleId() => _articles.doc().id;

  Future<UserArticleModel> createArticleForCurrentUser(
      ArticleCreateRequest request) async {
    final user = _auth.currentUser;
    if (user == null) throw const UnauthenticatedException();
    try {
      final model = UserArticleModel(
        id: request.id,
        authorId: user.uid,
        authorEmail: user.email,
        authorName: user.displayName,
        authorPhotoUrl: user.photoURL,
        title: request.title,
        description: request.description,
        content: request.content,
        thumbnailUrl: request.thumbnailUrl,
        thumbnailPath: request.thumbnailPath,
        publishedAt: DateTime.now(),
      );
      await _articles.doc(request.id).set({
        ...model.toMap(),
        'publishedAt': FieldValue.serverTimestamp(),
      });
      return model;
    } on FirebaseException catch (e) {
      throw UploadFailedException(e.message ?? e.code);
    }
  }

  Future<UserArticleModel> updateArticleForCurrentUser(
      ArticleUpdateRequest request) async {
    final user = _auth.currentUser;
    if (user == null) throw const UnauthenticatedException();
    try {
      final existing = await _readRaw(request.articleId);
      if (existing == null) {
        throw const UploadFailedException('Article not found.');
      }
      if (existing.authorId != user.uid) {
        throw const UploadFailedException(
            'You cannot edit other authors\' articles.');
      }
      final thumbnailUrl = request.newThumbnailUrl ?? existing.thumbnailUrl!;
      final thumbnailPath = request.newThumbnailPath ?? existing.thumbnailPath;
      final updated = UserArticleModel(
        id: request.articleId,
        authorId: existing.authorId,
        authorEmail: user.email,
        authorName: user.displayName,
        authorPhotoUrl: user.photoURL,
        title: request.title,
        description: request.description,
        content: request.content,
        thumbnailUrl: thumbnailUrl,
        thumbnailPath: thumbnailPath,
        publishedAt: existing.publishedAt,
      );
      await _articles.doc(request.articleId).set({
        ...updated.toMap(),
        'publishedAt': Timestamp.fromDate(existing.publishedAt),
      });
      return updated;
    } on FirebaseException catch (e) {
      throw UploadFailedException(e.message ?? e.code);
    }
  }

  Future<List<UserArticleModel>> getMyArticles() async {
    final user = _auth.currentUser;
    if (user == null) throw const UnauthenticatedException();
    try {
      final snap = await _articles
          .where('authorId', isEqualTo: user.uid)
          .orderBy('publishedAt', descending: true)
          .get();
      return snap.docs.map(_toModel).toList();
    } on FirebaseException catch (e) {
      throw UploadFailedException(e.message ?? e.code);
    }
  }

  Future<List<UserArticleModel>> getAllArticles() async {
    try {
      final snap =
          await _articles.orderBy('publishedAt', descending: true).get();
      return snap.docs.map(_toModel).toList();
    } on FirebaseException catch (e) {
      throw UploadFailedException(e.message ?? e.code);
    }
  }

  Future<String?> deleteArticleForCurrentUser(String articleId) async {
    final user = _auth.currentUser;
    if (user == null) throw const UnauthenticatedException();
    try {
      final existing = await _readRaw(articleId);
      if (existing == null) return null;
      if (existing.authorId != user.uid) {
        throw const UploadFailedException(
            'You cannot delete other authors\' articles.');
      }
      await _articles.doc(articleId).delete();
      return existing.thumbnailPath;
    } on FirebaseException catch (e) {
      throw UploadFailedException(e.message ?? e.code);
    }
  }

  Future<void> refreshAuthorSnapshotsForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw const UnauthenticatedException();
    try {
      final snap =
          await _articles.where('authorId', isEqualTo: user.uid).get();
      if (snap.docs.isEmpty) return;
      final patch = <String, dynamic>{
        if (user.displayName != null) 'authorName': user.displayName,
        if (user.email != null) 'authorEmail': user.email,
        if (user.photoURL != null) 'authorPhotoUrl': user.photoURL,
      };
      if (patch.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, patch);
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw UploadFailedException(e.message ?? e.code);
    }
  }

  Future<UserArticleModel?> _readRaw(String id) async {
    final doc = await _articles.doc(id).get();
    if (!doc.exists) return null;
    return _toModel(doc);
  }

  UserArticleModel _toModel(DocumentSnapshot<Map<String, dynamic>> doc) {
    final raw = doc.data()!;
    final published = raw['publishedAt'];
    return UserArticleModel.fromRawData(
      id: doc.id,
      data: {
        ...raw,
        'publishedAt':
            published is Timestamp ? published.toDate() : DateTime.now(),
      },
    );
  }
}
