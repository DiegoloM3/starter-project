import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/page.dart';

abstract class ArticleRepository {
  // API methods
  Future<DataState<PageEntity<ArticleEntity>>> getNewsArticles({
    required int page,
    int size = 10,
    int? total,
  });
  Future<DataState<void>> createArticle({
    required ArticleEntity article,
    required File image,
  });

  // Database methods
  Future<DataState<List<ArticleEntity>>> getSavedArticles();

  Future<DataState<void>> saveArticle(ArticleEntity article);

  Future<DataState<void>> removeArticle(ArticleEntity article);

  Future<DataState<ArticleEntity?>> getSavedArticle(String id);
}
