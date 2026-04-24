import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/user_articles_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/user_articles_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/models/user_article_model.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/upload_thumbnail_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

/// Firestore- and Storage-backed implementation of [UserArticleRepository].
///
/// The only layer that ever catches Firebase exceptions. Everything above
/// (use cases, cubits, UI) sees a domain [AppFailure] Either instead.
class UserArticleRepositoryImpl implements UserArticleRepository {
  UserArticleRepositoryImpl(this._firestore, this._storage);

  final UserArticlesFirestoreDataSource _firestore;
  final UserArticlesStorageDataSource _storage;

  @override
  Future<Either<AppFailure, List<UserArticleEntity>>> getMyArticles(
    String authorId,
  ) {
    return _guard(() async {
      final docs = await _firestore.getMyArticles(authorId);
      return docs
          .map((data) => UserArticleModel.fromFirestore(data).toEntity())
          .toList();
    });
  }

  @override
  Future<Either<AppFailure, UserArticleEntity>> publishArticle(
    PublishArticleParams params,
  ) {
    return _guard(() async {
      final id =
          params.id.isNotEmpty ? params.id : _firestore.reserveId();
      final payload = UserArticleModel.createPayload(
        id: id,
        authorId: params.authorId,
        authorName: params.authorName,
        title: params.title,
        description: params.description,
        content: params.content,
        thumbnailURL: params.thumbnailURL,
        tags: params.tags,
      );
      final written = await _firestore.createArticle(payload);
      return UserArticleModel.fromFirestore(written).toEntity();
    });
  }

  @override
  Future<Either<AppFailure, UserArticleEntity>> updateArticle(
    UpdateArticleParams params,
  ) {
    return _guard(() async {
      final payload = UserArticleModel.updatePayload(
        title: params.title,
        description: params.description,
        content: params.content,
        thumbnailURL: params.thumbnailURL,
        tags: params.tags,
      );
      final written = await _firestore.updateArticle(params.id, payload);
      return UserArticleModel.fromFirestore(written).toEntity();
    });
  }

  @override
  Future<Either<AppFailure, Unit>> deleteArticle(
    DeleteArticleParams params,
  ) {
    return _guard(() async {
      await _firestore.deleteArticle(params.id);
      return unit;
    });
  }

  @override
  Future<Either<AppFailure, String>> uploadThumbnail(
    UploadThumbnailParams params,
  ) {
    return _guard(() async {
      return _storage.uploadThumbnail(
        authorId: params.authorId,
        articleId: params.articleId,
        fileName: params.fileName,
        bytes: params.bytes,
        contentType: params.contentType,
      );
    });
  }

  /// Single place we map Firebase errors onto the domain failure
  /// hierarchy. Keeps `FirebaseException` from leaking into use cases.
  Future<Either<AppFailure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      final value = await action();
      return Right(value);
    } on FirebaseException catch (e) {
      return Left(_mapFirebase(e));
    } catch (error, stackTrace) {
      return Left(
        AppFailure.unknown(cause: error, stackTrace: stackTrace),
      );
    }
  }

  AppFailure _mapFirebase(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
      case 'unauthenticated':
        return AppFailure.auth(message: e.message ?? e.code);
      case 'unavailable':
      case 'deadline-exceeded':
      case 'aborted':
        return AppFailure.network(message: e.message ?? e.code);
      case 'not-found':
        return AppFailure.validation(field: 'id', reason: 'not found');
      default:
        return AppFailure.unknown(cause: e);
    }
  }
}
