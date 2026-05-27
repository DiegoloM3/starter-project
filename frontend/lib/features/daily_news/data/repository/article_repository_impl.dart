import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;

  ArticleRepositoryImpl(this._newsApiService, this._appDatabase);

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final entities = httpResponse.data.map((model) => model.toEntity()).toList();
        return DataSuccess(entities);
      } else {
        return DataFailed(
          AppException(
            message: httpResponse.response.statusMessage ?? 'Unknown error',
            code: '${httpResponse.response.statusCode}',
          ),
        );
      }
    } on DioError catch (e) {
      return DataFailed(
        AppException(
          message: e.message ?? 'Network error',
          code: e.type.name,
        ),
      );
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    final models = await _appDatabase.articleDAO.getArticles();
    return models.map((model) => model.toEntity()).toList();
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
  Future<DataState<ArticleEntity>> createArticle(ArticleEntity article) {
    throw UnimplementedError('Firestore implementation pending — Phase 5');
  }

  @override
  Future<DataState<ArticleEntity>> updateArticle(ArticleEntity article) {
    throw UnimplementedError('Firestore implementation pending — Phase 5');
  }

  @override
  Future<DataState<void>> deleteArticle(String articleId) {
    throw UnimplementedError('Firestore implementation pending — Phase 5');
  }

  @override
  Stream<DataState<List<ArticleEntity>>> getPublishedArticles() {
    throw UnimplementedError('Firestore implementation pending — Phase 5');
  }

  @override
  Stream<DataState<List<ArticleEntity>>> getUserArticles(String userId) {
    throw UnimplementedError('Firestore implementation pending — Phase 5');
  }

  @override
  Stream<DataState<List<ArticleEntity>>> getDraftArticles(String userId) {
    throw UnimplementedError('Firestore implementation pending — Phase 5');
  }

  @override
  Future<DataState<String>> uploadThumbnail({
    required String articleId,
    required String filePath,
  }) {
    throw UnimplementedError('Firestore implementation pending — Phase 5');
  }
}