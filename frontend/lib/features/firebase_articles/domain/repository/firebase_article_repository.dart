import 'dart:io' show File;

import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/params/create_article_params.dart';

import '../entities/generated_article.dart';

abstract class FirebaseArticleRepository {
  Future<List<ArticleEntity>> getArticles();

  Future<ArticleEntity> createArticle(CreateArticleParams params);

  Future<void> deleteArticle(String articleId);

  Future<GeneratedArticle> generateArticleContent(String prompt);

  Future<File> generateArticleImage(String articleTitle);
}
