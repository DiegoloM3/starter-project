import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/upload_article/data/data_sources/upload_article_firebase_data_source.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/upload_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/upload_article_repository.dart';

class UploadArticleRepositoryImpl implements UploadArticleRepository {
  final UploadArticleFirebaseDataSource _dataSource;

  UploadArticleRepositoryImpl(this._dataSource);

  @override
  Future<DataState<ArticleEntity>> uploadArticle(UploadArticleEntity article) async {
    try {
      final uploadedArticle = await _dataSource.uploadArticle(article);
      return DataSuccess<ArticleEntity>(uploadedArticle);
    } catch (error) {
      return DataFailed<ArticleEntity>(
        DioError(
          requestOptions: RequestOptions(path: '/articles'),
          error: error,
          type: DioErrorType.other,
        ),
      );
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getMyUploadedArticles() async {
    try {
      final uploadedArticles = await _dataSource.getMyUploadedArticles();
      return DataSuccess<List<ArticleEntity>>(uploadedArticles);
    } catch (error) {
      return DataFailed<List<ArticleEntity>>(
        DioError(
          requestOptions: RequestOptions(path: '/articles'),
          error: error,
          type: DioErrorType.other,
        ),
      );
    }
  }
}
