import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';
import '../data_sources/remote/firebase_article_data_source.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  final FirebaseArticleDataSource _firebaseArticleDataSource;
  ArticleRepositoryImpl(this._newsApiService, this._appDatabase, this._firebaseArticleDataSource);
  
  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
   try {
    final httpResponse = await _newsApiService.getNewsArticles(
      apiKey:newsAPIKey,
      country:countryQuery,
      category:categoryQuery,
    );

    if (httpResponse.response.statusCode == HttpStatus.ok) {
      final publishedArticles = await _appDatabase.articleDAO.getArticles();
      final firebaseArticles = await _firebaseArticleDataSource.getPublishedArticles();
      final firebaseModels = firebaseArticles.map(ArticleModel.fromEntity).toList();
      return DataSuccess([...firebaseModels, ...publishedArticles, ...httpResponse.data]);
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
  Future<void> publishArticle(ArticleEntity article) {
    return _publishArticleToFirebaseAndCache(article);
  }

  Future<void> _publishArticleToFirebaseAndCache(ArticleEntity article) async {
    await _firebaseArticleDataSource.publishArticle(article);
    await _appDatabase.articleDAO.insertArticle(ArticleModel.fromEntity(article));
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
  
}