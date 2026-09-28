import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';

/// Contract for user-created articles stored in Firestore.
abstract interface class UserArticleRepository {
  Future<DataState<List<ArticleEntity>>> getAllUserArticles();

  Future<DataState<List<ArticleEntity>>> getUserArticles(String userId);

  Future<DataState<void>> createUserArticle(
    ArticleEntity article, {
    File? imageFile,
  });

  Future<DataState<void>> updateUserArticle(
    ArticleEntity article, {
    File? imageFile,
  });

  Future<DataState<void>> deleteUserArticle(String articleId);
}
