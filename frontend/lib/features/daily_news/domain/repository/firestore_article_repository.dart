import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class FirestoreArticleRepository {
  Future<DataState<List<ArticleEntity>>> getFirestoreArticles();

  Future<DataState<ArticleEntity>> createArticle(
    ArticleEntity article,
    List<String> imagePaths,
  );

  Future<DataState<ArticleEntity>> updateArticle(
    ArticleEntity article,
    List<String> newImagePaths,
    List<String> existingImageUrls,
  );

  Future<DataState<bool>> deleteArticle(String documentId);
}
