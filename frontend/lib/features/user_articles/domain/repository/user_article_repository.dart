import 'dart:typed_data';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

abstract class UserArticleRepository {
  Future<DataState<List<UserArticleEntity>>> getArticles({
    int limit = 10,
    DateTime? startAfter,
  });

  Future<DataState<UserArticleEntity>> getArticleById(String id);

  Future<DataState<UserArticleEntity>> createArticle({
    required String authorName,
    required String title,
    required String description,
    required String content,
    required Uint8List? thumbnailBytes,
    required String? thumbnailExtension,
    required bool isDraft,
  });

  Future<DataState<UserArticleEntity>> updateArticle({
    required String id,
    required String authorName,
    required String title,
    required String description,
    required String content,
    Uint8List? newThumbnailBytes,
    String? newThumbnailExtension,
    required bool isDraft,
  });

  Future<DataState<bool>> deleteArticle(String id);
}
