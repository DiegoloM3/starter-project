import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/article_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/cloudinary_service.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/models/user_article_model.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

/// Implementation of UserArticleRepository.
/// Coordinates between ArticleRemoteDataSource (Firestore) and CloudinaryService.
class UserArticleRepositoryImpl implements UserArticleRepository {
  final ArticleRemoteDataSource _articleRemoteDataSource;
  final CloudinaryService _cloudinaryService;

  UserArticleRepositoryImpl({
    required ArticleRemoteDataSource articleRemoteDataSource,
    required CloudinaryService cloudinaryService,
  })  : _articleRemoteDataSource = articleRemoteDataSource,
        _cloudinaryService = cloudinaryService;

  @override
  Future<DataState<UserArticleEntity>> createArticle(
    UserArticleEntity article,
  ) async {
    try {
      // Convert entity to model
      final articleModel = UserArticleModel.fromEntity(article);

      // Create article in Firestore
      final createdArticle = await _articleRemoteDataSource.createArticle(
        articleModel,
      );

      return DataSuccess(createdArticle);
    } catch (e) {
      return DataFailed(Exception('Failed to create article: ${e.toString()}'));
    }
  }

  @override
  Future<DataState<UserArticleEntity>> updateArticle(
    UserArticleEntity article,
  ) async {
    try {
      // Convert entity to model
      final articleModel = UserArticleModel.fromEntity(article);

      // Update article in Firestore
      final updatedArticle = await _articleRemoteDataSource.updateArticle(
        articleModel,
      );

      return DataSuccess(updatedArticle);
    } catch (e) {
      return DataFailed(Exception('Failed to update article: ${e.toString()}'));
    }
  }

  @override
  Future<DataState<void>> deleteArticle(String articleId) async {
    try {
      await _articleRemoteDataSource.deleteArticle(articleId);
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(Exception('Failed to delete article: ${e.toString()}'));
    }
  }

  @override
  Future<DataState<UserArticleEntity>> getArticleById(String articleId) async {
    try {
      final article = await _articleRemoteDataSource.getArticleById(articleId);

      if (article == null) {
        return DataFailed(Exception('Article not found'));
      }

      return DataSuccess(article);
    } catch (e) {
      return DataFailed(Exception('Failed to get article: ${e.toString()}'));
    }
  }

  @override
  Future<DataState<List<UserArticleEntity>>> getPublishedArticles() async {
    try {
      final articles = await _articleRemoteDataSource.getPublishedArticles();
      return DataSuccess(articles);
    } catch (e) {
      return DataFailed(
        Exception('Failed to get published articles: ${e.toString()}'),
      );
    }
  }

  @override
  Future<DataState<List<UserArticleEntity>>> getUserArticles(
    String userId,
  ) async {
    try {
      final articles = await _articleRemoteDataSource.getUserArticles(userId);
      return DataSuccess(articles);
    } catch (e) {
      return DataFailed(
        Exception('Failed to get user articles: ${e.toString()}'),
      );
    }
  }

  @override
  Future<DataState<List<UserArticleEntity>>> getArticlesByCategory(
    String category,
  ) async {
    try {
      final articles = await _articleRemoteDataSource.getArticlesByCategory(
        category,
      );
      return DataSuccess(articles);
    } catch (e) {
      return DataFailed(
        Exception('Failed to get articles by category: ${e.toString()}'),
      );
    }
  }

  @override
  Future<DataState<UserArticleEntity>> publishArticle(String articleId) async {
    try {
      final publishedArticle = await _articleRemoteDataSource.publishArticle(
        articleId,
      );
      return DataSuccess(publishedArticle);
    } catch (e) {
      return DataFailed(
        Exception('Failed to publish article: ${e.toString()}'),
      );
    }
  }

  @override
  Future<DataState<UserArticleEntity>> unpublishArticle(
    String articleId,
  ) async {
    try {
      final unpublishedArticle =
          await _articleRemoteDataSource.unpublishArticle(
        articleId,
      );
      return DataSuccess(unpublishedArticle);
    } catch (e) {
      return DataFailed(
        Exception('Failed to unpublish article: ${e.toString()}'),
      );
    }
  }

  @override
  Future<DataState<String>> uploadImage(File imageFile) async {
    try {
      // Upload image to Cloudinary with 'articles' folder
      final imageUrl = await _cloudinaryService.uploadImage(
        imageFile,
        folder: 'articles',
      );
      return DataSuccess(imageUrl);
    } catch (e) {
      return DataFailed(Exception('Failed to upload image: ${e.toString()}'));
    }
  }
}
