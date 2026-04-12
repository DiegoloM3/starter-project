import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';

class FakeFirestoreArticleRepository implements FirestoreArticleRepository {
  DataState<List<ArticleEntity>>? getResult;
  DataState<ArticleEntity>? createResult;
  DataState<ArticleEntity>? updateResult;
  DataState<bool>? deleteResult;
  String? lastDeletedId;

  @override
  Future<DataState<List<ArticleEntity>>> getFirestoreArticles() async =>
      getResult ?? const DataSuccess([]);

  @override
  Future<DataState<ArticleEntity>> createArticle(
    ArticleEntity article,
    List<String> imagePaths,
  ) async =>
      createResult ?? DataSuccess(article);

  @override
  Future<DataState<ArticleEntity>> updateArticle(
    ArticleEntity article,
    List<String> newImagePaths,
    List<String> existingImageUrls,
  ) async =>
      updateResult ?? DataSuccess(article);

  @override
  Future<DataState<bool>> deleteArticle(String documentId) async {
    lastDeletedId = documentId;
    return deleteResult ?? const DataSuccess(true);
  }
}
