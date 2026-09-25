import 'dart:typed_data';

import 'package:news_app_clean_architecture/core/data/data_sources/remote/current_user_data_source.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/user_article_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/user_article_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/models/user_article_model.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_content_repository.dart';

/// Also the [AccountContentRepository]: a user's articles are the content
/// that has to go when their account is deleted.
class UserArticleRepositoryImpl
    implements UserArticleRepository, AccountContentRepository {
  final UserArticleFirestoreDataSource _firestoreDataSource;
  final UserArticleStorageDataSource _storageDataSource;
  final CurrentUserDataSource _currentUserDataSource;

  UserArticleRepositoryImpl(
    this._firestoreDataSource,
    this._storageDataSource,
    this._currentUserDataSource,
  );

  @override
  Future<DataState<List<UserArticleEntity>>> getArticles({
    int limit = 10,
    DateTime? startAfter,
  }) async {
    try {
      final authorId = await _currentUserDataSource.ensureSignedIn();
      final models = await _firestoreDataSource.getArticles(
        authorId: authorId,
        limit: limit,
        startAfter: startAfter,
      );
      return DataSuccess(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserArticleEntity>> getArticleById(String id) async {
    try {
      final model = await _firestoreDataSource.getArticleById(id);
      return DataSuccess(model.toEntity());
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserArticleEntity>> createArticle({
    required String authorName,
    required String title,
    required String description,
    required String content,
    required Uint8List? thumbnailBytes,
    required String? thumbnailExtension,
    required bool isDraft,
  }) async {
    try {
      final authorId = await _currentUserDataSource.ensureSignedIn();
      final docRef = _firestoreDataSource.newDocumentReference();

      // A draft can be saved with no cover photo at all -- only upload one
      // when there actually is one to upload.
      final thumbnailURL = thumbnailBytes != null && thumbnailExtension != null
          ? await _storageDataSource.uploadThumbnail(
              articleId: docRef.id,
              bytes: thumbnailBytes,
              extension: thumbnailExtension,
              authorId: authorId,
            )
          : '';

      final model = UserArticleModel(
        id: docRef.id,
        authorId: authorId,
        authorName: authorName,
        title: title,
        description: description,
        content: content,
        thumbnailURL: thumbnailURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDraft: isDraft,
      );

      await _firestoreDataSource.createArticle(docRef.id, model.toMap());

      return DataSuccess(model.toEntity());
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserArticleEntity>> updateArticle({
    required String id,
    required String authorName,
    required String title,
    required String description,
    required String content,
    Uint8List? newThumbnailBytes,
    String? newThumbnailExtension,
    required bool isDraft,
  }) async {
    try {
      final existing = await _firestoreDataSource.getArticleById(id);

      var thumbnailURL = existing.thumbnailURL;
      if (newThumbnailBytes != null && newThumbnailExtension != null) {
        thumbnailURL = await _storageDataSource.uploadThumbnail(
          articleId: id,
          bytes: newThumbnailBytes,
          extension: newThumbnailExtension,
          authorId: existing.authorId,
        );
      }

      final updated = UserArticleModel(
        id: id,
        authorId: existing.authorId,
        authorName: authorName,
        title: title,
        description: description,
        content: content,
        thumbnailURL: thumbnailURL,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        isDraft: isDraft,
      );

      await _firestoreDataSource.updateArticle(id, updated.toMap());

      return DataSuccess(updated.toEntity());
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<bool>> deleteArticle(String id) async {
    try {
      final article = await _firestoreDataSource.getArticleById(id);
      await _firestoreDataSource.deleteArticle(id);
      // After the document, so a failure here can only leave an unused file
      // behind, never an article pointing at a missing photo.
      // storage.rules can allow this on its own regardless of this
      // ordering: it checks the file's own stamped-on authorId, not
      // anything about whether the Firestore document still exists.
      await _deleteThumbnailQuietly(article.thumbnailURL);
      return const DataSuccess(true);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> deleteAllContent() async {
    try {
      final authorId = await _currentUserDataSource.ensureSignedIn();
      final articles =
          await _firestoreDataSource.getAllArticles(authorId: authorId);
      await _firestoreDataSource
          .deleteArticles([for (final article in articles) article.id]);
      for (final article in articles) {
        await _deleteThumbnailQuietly(article.thumbnailURL);
      }
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(e);
    }
  }

  // A photo that won't delete (already gone, or no connection) leaves an
  // unused file behind at worst; it shouldn't stop the article itself from
  // being deleted. A draft saved without a photo has none to delete.
  Future<void> _deleteThumbnailQuietly(String url) async {
    if (url.isEmpty) return;
    try {
      await _storageDataSource.deleteThumbnail(url);
    } catch (_) {}
  }
}
