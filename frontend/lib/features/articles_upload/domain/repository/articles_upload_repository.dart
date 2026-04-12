import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/params/update_article_params.dart';

abstract class ArticlesUploadRepository {
  Future<DataState<List<ArticleUploadEntity>>> getAllArticles();

  Future<DataState<ArticleUploadEntity>> getArticleById(String id);

  Future<DataState<ArticleUploadEntity>> createArticle(
    CreateArticleParams params,
  );

  Future<DataState<ArticleUploadEntity>> updateArticle(
    UpdateArticleParams params,
  );

  Future<DataState<void>> deleteArticle(String id);

  Future<DataState<List<ArticleUploadEntity>>> fetchRemoteAndSync();

  Future<DataState<List<ArticleUploadEntity>>> fetchNextPage(
    DateTime lastPublishedAt,
  );

  int get pageSize;
}
