import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/news/data/models/article.dart';

/// Firestore/Storage data source for user-created articles.
@injectable
class UserArticlesFirebaseService {
  static final _log = Logger('UserArticlesFirebaseService');

  final FirebaseFirestore _firestoreDb = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _articlesCollection = kArticlesCollection;
  static const String _thumbnailsFolder = kArticleThumbnailsFolder;

  /// Uploads [imageFile] to Firebase Cloud Storage under [_thumbnailsFolder]
  /// and returns its download URL. Returns null if [imageFile] is null.
  Future<String?> uploadThumbnail(File? imageFile) async {
    if (imageFile == null) return null;

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.uri.pathSegments.last}';
    final ref = _storage.ref().child('$_thumbnailsFolder/$fileName');

    _log.info('uploadThumbnail → uploading to $_thumbnailsFolder/$fileName');
    final task = await ref.putFile(imageFile);
    final url = await task.ref.getDownloadURL();
    _log.info('uploadThumbnail → uploaded, url=$url');
    return url;
  }

  /// Returns every user-created article, newest first by `publishedAt`.
  /// Reads are public, so no login is required to call this.
  Future<List<ArticleModel>> getAllUserArticles() async {
    _log.info('getAllUserArticles → querying all user articles');

    final snapshot = await _firestoreDb
        .collection(_articlesCollection)
        .orderBy('publishedAt', descending: true)
        .get();

    final articles =
        snapshot.docs.map((doc) => ArticleModel.fromJson(doc.data())).toList();
    _log.info('getAllUserArticles → found ${articles.length} articles');
    return articles;
  }

  /// Returns the articles created by [userId], newest first by `publishedAt`.
  /// Returns an empty list when [userId] is blank instead of querying.
  Future<List<ArticleModel>> getUserArticles(String userId) async {
    if (userId.trim().isEmpty) return [];

    _log.info('getUserArticles → querying articles for user $userId');
    final snapshot = await _firestoreDb
        .collection(_articlesCollection)
        .where('authorId', isEqualTo: userId)
        .orderBy('publishedAt', descending: true)
        .get();

    final articles =
        snapshot.docs.map((doc) => ArticleModel.fromJson(doc.data())).toList();
    _log.info('getUserArticles → found ${articles.length} articles');
    return articles;
  }

  /// Overwrites the Firestore document for [article]. The [article.id]
  /// must match an existing document id. Throws [StateError] when the id
  /// is missing or blank.
  Future<void> updateUserArticle(ArticleModel article) async {
    final articleId = article.id?.trim() ?? '';
    if (articleId.isEmpty) {
      throw StateError('Cannot update an article without an id.');
    }
    _log.info('updateUserArticle → updating article $articleId');
    await _firestoreDb
        .collection(_articlesCollection)
        .doc(articleId)
        .update(article.toJson());
    _log.info('updateUserArticle → updated article $articleId');
  }

  /// Deletes the Firestore document with [articleId].
  /// Throws [StateError] when [articleId] is blank.
  Future<void> deleteUserArticle(String articleId) async {
    if (articleId.trim().isEmpty) {
      throw StateError('Cannot delete an article without an id.');
    }
    _log.info('deleteUserArticle → deleting article $articleId');
    await _firestoreDb.collection(_articlesCollection).doc(articleId).delete();
    _log.info('deleteUserArticle → deleted article $articleId');
  }

  /// Saves [article] to Firestore. The [article.urlToImage] should already
  /// contain the Storage download URL before calling this.
  Future<DocumentReference<Map<String, dynamic>>> createUserArticle(
      ArticleModel article) async {
    _log.info('createUserArticle → saving to Firestore');
    final ref = await _firestoreDb
        .collection(_articlesCollection)
        .add(article.toJson());


    // TODO(sgalindo) this maybe can be done before the actual element
    // is created with set, but right now the entity is inmutable,
    // thus we cannot change the ID of the field itself before is 
    // inserted.
    await _firestoreDb
        .collection(_articlesCollection)
        .doc(ref.id)
        .update({"id": ref.id});

    _log.info('createUserArticle → saved with id=${ref.id}');
    return ref;
  }
}
