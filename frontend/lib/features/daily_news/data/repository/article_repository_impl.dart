import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
<<<<<<< HEAD
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  ArticleRepositoryImpl(this._newsApiService,this._appDatabase);
  
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
=======
import 'package:news_app_clean_architecture/core/resources/app_error.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;

  ArticleRepositoryImpl(this._newsApiService, this._appDatabase);

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: kNewsApiKey,
        country: kCountryQuery,
        category: kCategoryQuery,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return DataSuccess(httpResponse.data.map((m) => m.toEntity()).toList());
      } else {
        return DataFailed(AppError(
          message: httpResponse.response.statusMessage ?? 'Server error',
          statusCode: httpResponse.response.statusCode,
        ));
      }
    } on DioError catch (e) {
      return DataFailed(AppError(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      ));
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    final models = await _appDatabase.articleDao.getArticles();
    return models.map((m) => m.toEntity()).toList();
>>>>>>> fbce432 (Finish PR (project setup))
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
<<<<<<< HEAD
    return _appDatabase.articleDAO.deleteArticle(ArticleModel.fromEntity(article));
=======
    return _appDatabase.articleDao.deleteArticle(ArticleModel.fromEntity(article));
>>>>>>> fbce432 (Finish PR (project setup))
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
<<<<<<< HEAD
    return _appDatabase.articleDAO.insertArticle(ArticleModel.fromEntity(article));
  }
  
}
=======
    return _appDatabase.articleDao.insertArticle(ArticleModel.fromEntity(article));
  }
}
>>>>>>> fbce432 (Finish PR (project setup))
