import 'dart:io';

import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/page.dart';

abstract class NewsService {
  Future<PageModel<ArticleModel>> getNewsArticles({
    required int page,
    int size = 10,
    int? total,
  });
  Future<void> saveArticle(ArticleModel article);
  Future<String> uploadImage(File file);
}
