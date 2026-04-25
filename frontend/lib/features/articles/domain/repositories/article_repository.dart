import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';

abstract class ArticleRepository {
  Future<DataState<List<ArticleEntity>>> getArticles({String? category});

  Future<DataState<List<ArticleEntity>>> getMyArticles(
    String authorId, {
    String? status,
  });

  Future<DataState<ArticleEntity>> getArticleById(String id);

  Future<DataState<ArticleEntity>> createArticle(
    ArticleEntity article, {
    File? thumbnail,
  });

  Future<DataState<ArticleEntity>> updateArticle(
    ArticleEntity article, {
    File? thumbnail,
  });

  Future<DataState<void>> deleteArticle(String id);
}
