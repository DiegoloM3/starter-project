import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article.dart';

/// Abstract repository interface for user article operations.
/// The data layer will implement this interface.
abstract class UserArticleRepository {
  /// Creates a new article.
  /// Returns [DataState<UserArticleEntity>] with the created article on success.
  Future<DataState<UserArticleEntity>> createArticle(UserArticleEntity article);

  /// Updates an existing article.
  /// Returns [DataState<UserArticleEntity>] with the updated article on success.
  Future<DataState<UserArticleEntity>> updateArticle(UserArticleEntity article);

  /// Deletes an article by its ID.
  /// Returns [DataState<void>] indicating success or failure.
  Future<DataState<void>> deleteArticle(String articleId);

  /// Gets a single article by its ID.
  /// Returns [DataState<UserArticleEntity>] with the article on success.
  Future<DataState<UserArticleEntity>> getArticleById(String articleId);

  /// Gets all published articles (for the public feed).
  /// Returns [DataState<List<UserArticleEntity>>] with the articles on success.
  Future<DataState<List<UserArticleEntity>>> getPublishedArticles();

  /// Gets all articles by a specific user (including drafts for the owner).
  /// Returns [DataState<List<UserArticleEntity>>] with the articles on success.
  Future<DataState<List<UserArticleEntity>>> getUserArticles(String userId);

  /// Gets articles filtered by category.
  /// Returns [DataState<List<UserArticleEntity>>] with the filtered articles.
  Future<DataState<List<UserArticleEntity>>> getArticlesByCategory(
      String category);

  /// Publishes a draft article (sets isDraft to false).
  /// Returns [DataState<UserArticleEntity>] with the published article on success.
  Future<DataState<UserArticleEntity>> publishArticle(String articleId);

  /// Unpublishes an article (sets isDraft to true).
  /// Returns [DataState<UserArticleEntity>] with the unpublished article on success.
  Future<DataState<UserArticleEntity>> unpublishArticle(String articleId);

  /// Uploads an image and returns the URL.
  /// Returns [DataState<String>] with the image URL on success.
  Future<DataState<String>> uploadImage(File imageFile);
}
