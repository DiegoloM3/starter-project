import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/upload_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/upload_article_repository.dart';

class UploadArticleRepositoryMock implements UploadArticleRepository {
  @override
  Future<DataState<ArticleEntity>> uploadArticle(UploadArticleEntity article) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    try {
      final uploadedArticle = ArticleEntity(
        author: article.author,
        title: article.title,
        description: article.description,
        content: article.content,
        url: article.url,
        urlToImage: article.urlToImage,
        publishedAt: DateTime.now().toIso8601String(),
      );

      return DataSuccess<ArticleEntity>(uploadedArticle);
    } on Exception catch (e) {
      return DataFailed<ArticleEntity>(
        DioError(
          requestOptions: RequestOptions(path: '/articles'),
          error: e.toString(),
          type: DioErrorType.other,
        ),
      );
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getMyUploadedArticles() async {
    return const DataSuccess<List<ArticleEntity>>(<ArticleEntity>[]);
  }
}
