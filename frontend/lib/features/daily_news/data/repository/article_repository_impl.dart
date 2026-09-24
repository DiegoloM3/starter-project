import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firebase_storage_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_article_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_upload_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  final FirestoreArticleService _firestoreService;
  final FirebaseStorageService _storageService;

  ArticleRepositoryImpl(
    this._newsApiService,
    this._appDatabase,
    this._firestoreService,
    this._storageService,
  );
  
  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
   try {
    final httpResponse = await _newsApiService.getNewsArticles(
      apiKey:newsAPIKey,
      country:countryQuery,
      category:categoryQuery,
    );

    if (httpResponse.response.statusCode == HttpStatus.ok) {
      return DataSuccess(httpResponse.data);
    } else {
      return DataFailed(
        DioError(
          error: httpResponse.response.statusMessage,
          response: httpResponse.response,
          type: DioErrorType.response,
          requestOptions: httpResponse.response.requestOptions
        )
      );
    }
   } on DioError catch(e){
    return DataFailed(e);
   }
  }

  @override
  Future<List<ArticleModel>> getSavedArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.insertArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<DataState<ArticleEntity>> uploadArticle(CreateArticleParams params) async {
    try {
      final thumbnailFile = File(params.thumbnailPath);

      final thumbnailUrl = await _storageService.uploadThumbnail(
        thumbnailFile,
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      final articleModel = ArticleModel(
        title: params.title,
        content: params.content,
        author: params.author,
        description: params.description,
        category: params.category,
        articleType: 'user_uploaded',
        thumbnailURL: thumbnailUrl,
        isPublished: true,
        uploadedAt: DateTime.now().toIso8601String(),
      );

      await _firestoreService.uploadArticle(articleModel);

      return DataSuccess(articleModel);
    } catch (e) {
      return DataFailed(
        DioError(
          requestOptions: RequestOptions(path: ''),
          error: e.toString(),
          type: DioErrorType.response,
        ),
      );
    }
  }

  @override
  Future<DataState<ArticleEntity>> updateArticle(UpdateArticleParams params) async {
    try {
      String? thumbnailUrl;

      if (params.thumbnailPath != null) {
        final thumbnailFile = File(params.thumbnailPath!);
        thumbnailUrl = await _storageService.uploadThumbnail(
          thumbnailFile,
          params.articleId,
        );
      }

      final articleModel = ArticleModel(
        title: params.title,
        content: params.content,
        author: params.author,
        description: params.description,
        category: params.category,
        thumbnailURL: thumbnailUrl,
      );

      await _firestoreService.updateArticle(params.articleId, articleModel);

      return DataSuccess(articleModel);
    } catch (e) {
      return DataFailed(
        DioError(
          requestOptions: RequestOptions(path: ''),
          error: e.toString(),
          type: DioErrorType.response,
        ),
      );
    }
  }

  @override
  Future<DataState<void>> deleteArticle(DeleteArticleParams params) async {
    try {
      await _storageService.deleteThumbnail(params.articleId);
      await _firestoreService.deleteArticle(params.articleId);
      return DataSuccess(null);
    } catch (e) {
      return DataFailed(
        DioError(
          requestOptions: RequestOptions(path: ''),
          error: e.toString(),
          type: DioErrorType.response,
        ),
      );
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getUserArticles(
    GetUserArticlesParams params,
  ) async {
    try {
      final articles = await _firestoreService.getUserArticles(
        params.userId,
        limit: params.limit,
      );
      return DataSuccess(articles);
    } catch (e) {
      return DataFailed(
        DioError(
          requestOptions: RequestOptions(path: ''),
          error: e.toString(),
          type: DioErrorType.response,
        ),
      );
    }
  }

  @override
  Future<DataState<void>> updateArticlePublishStatus(
    UpdatePublishStatusParams params,
  ) async {
    try {
      await _firestoreService.updatePublishStatus(
        params.articleId,
        params.isPublished,
      );
      return DataSuccess(null);
    } catch (e) {
      return DataFailed(
        DioError(
          requestOptions: RequestOptions(path: ''),
          error: e.toString(),
          type: DioErrorType.response,
        ),
      );
    }
  }
}