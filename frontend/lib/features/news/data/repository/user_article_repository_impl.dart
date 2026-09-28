import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/remote/user_articles_firebase_service.dart';
import 'package:news_app_clean_architecture/features/news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/user_article_repository.dart';

@LazySingleton(as: UserArticleRepository)
/// [UserArticleRepository] implementation over [UserArticlesFirebaseService].
class UserArticleRepositoryImpl implements UserArticleRepository {
  static final _log = Logger('UserArticleRepositoryImpl');

  final UserArticlesFirebaseService _firebaseService;

  UserArticleRepositoryImpl(this._firebaseService);

  /// [imageFile] is optional — pass it alongside the [article] when the user
  /// has picked a thumbnail. The upload happens before the Firestore write so
  /// the article is never saved with a missing image reference.
  @override
  Future<DataState<void>> createUserArticle(
    ArticleEntity article, {
    File? imageFile,
  }) async {
    try {
      final thumbnailUrl = await _firebaseService.uploadThumbnail(imageFile);
      _log.info('createUserArticle → thumbnailUrl=$thumbnailUrl');

      final model = ArticleModel.fromEntity(article).copyWith(
        urlToImage: thumbnailUrl ?? article.urlToImage,
      );

      await _firebaseService.createUserArticle(model);

      return DataSuccess(null);
    } catch (e, st) {
      _log.severe('createUserArticle → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  /// [imageFile] replaces the thumbnail only when provided; otherwise
  /// the [article.urlToImage] is kept untouched.
  @override
  Future<DataState<void>> updateUserArticle(
    ArticleEntity article, {
    File? imageFile,
  }) async {
    try {
      final thumbnailUrl = await _firebaseService.uploadThumbnail(imageFile);
      _log.info('updateUserArticle → thumbnailUrl=$thumbnailUrl');

      final model = ArticleModel.fromEntity(article).copyWith(
        urlToImage: thumbnailUrl ?? article.urlToImage,
      );

      await _firebaseService.updateUserArticle(model);

      return DataSuccess(null);
    } catch (e, st) {
      _log.severe('updateUserArticle → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  @override
  Future<DataState<void>> deleteUserArticle(String articleId) async {
    try {
      await _firebaseService.deleteUserArticle(articleId);
      return DataSuccess(null);
    } catch (e, st) {
      _log.severe('deleteUserArticle → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  @override
  /// Returns all user articles mapped to entities.
  Future<DataState<List<ArticleEntity>>> getAllUserArticles() async {
    try {
      final articles = await _firebaseService.getAllUserArticles();
      return DataSuccess(articles.map((m) => m.toEntity()).toList());
    } catch (e, st) {
      _log.severe('getAllUserArticles → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  @override
  /// Returns articles for [userId] mapped to entities.
  Future<DataState<List<ArticleEntity>>> getUserArticles(String userId) async {
    try {
      final articles = await _firebaseService.getUserArticles(userId);
      return DataSuccess(articles.map((m) => m.toEntity()).toList());
    } catch (e, st) {
      _log.severe('getUserArticles → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }
}
