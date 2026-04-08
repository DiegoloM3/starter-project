import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/upload_article.dart';

abstract class UploadArticleRepository {
  Future<DataState<ArticleEntity>> uploadArticle(UploadArticleEntity article);
  Future<DataState<List<ArticleEntity>>> getMyUploadedArticles();
}
