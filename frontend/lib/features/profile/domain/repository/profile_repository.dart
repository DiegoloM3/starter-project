import 'dart:io';

import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';

abstract class ProfileRepository {
  Future<DataState<List<ArticleEntity>>> getSavedArticles(
    String userId,
    int limit,
  );

  Future<DataState<List<ArticleEntity>>> getPublishedArticles(
    String authorId,
    int limit,
  );

  Future<DataState<bool>> deleteArticle(String articleId, String userId);

  Future<DataState<String>> uploadAvatar(File imageFile, String userId);
}
