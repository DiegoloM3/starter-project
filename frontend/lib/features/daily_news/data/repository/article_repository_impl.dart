import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/mappers/failure_mapper.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_article_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/firestore_article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/local_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/remote_news_repository.dart';

class ArticleRepositoryImpl
    implements
        RemoteNewsRepository,
        LocalArticleRepository,
        FirestoreArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  final FirestoreArticleService _firestoreService;

  ArticleRepositoryImpl(
    this._newsApiService,
    this._appDatabase,
    this._firestoreService,
  );

  // --- Remote News API ---

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final entities = httpResponse.data.map((m) => m.toEntity()).toList();
        return DataSuccess(entities);
      } else {
        return const DataFailed(ServerFailure());
      }
    } on DioException catch (e) {
      return DataFailed(mapDioFailure(e));
    }
  }

  // --- Local Database ---

  @override
  Future<DataState<List<ArticleEntity>>> getSavedArticles() async {
    try {
      final models = await _appDatabase.articleDAO.getArticles();
      final entities = models.map((m) => m.toEntity()).toList();
      return DataSuccess(entities);
    } on Exception {
      return const DataFailed(UnknownFailure());
    }
  }

  @override
  Future<DataState<bool>> removeArticle(ArticleEntity article) async {
    try {
      await _appDatabase.articleDAO
          .deleteArticle(ArticleModel.fromEntity(article));
      return const DataSuccess(true);
    } on Exception {
      return const DataFailed(UnknownFailure());
    }
  }

  @override
  Future<DataState<bool>> saveArticle(ArticleEntity article) async {
    try {
      await _appDatabase.articleDAO
          .insertArticle(ArticleModel.fromEntity(article));
      return const DataSuccess(true);
    } on Exception {
      return const DataFailed(UnknownFailure());
    }
  }

  // --- Firestore ---

  @override
  Future<DataState<List<ArticleEntity>>> getFirestoreArticles() async {
    try {
      final models = await _firestoreService.getArticles();
      final entities = models.map((m) => m.toEntity()).toList();
      return DataSuccess(entities);
    } on Exception catch (e) {
      return DataFailed(mapFirebaseFailure(e));
    }
  }

  @override
  Future<DataState<ArticleEntity>> createArticle(
    ArticleEntity article,
    List<String> imagePaths,
  ) async {
    try {
      final model = FirestoreArticleModel.fromEntity(article);
      final files = imagePaths.map((path) => File(path)).toList();
      final created = await _firestoreService.createArticle(model, files);
      return DataSuccess(created.toEntity());
    } on Exception catch (e) {
      return DataFailed(mapFirebaseFailure(e));
    }
  }

  @override
  Future<DataState<ArticleEntity>> updateArticle(
    ArticleEntity article,
    List<String> newImagePaths,
    List<String> existingImageUrls,
  ) async {
    try {
      final model = FirestoreArticleModel.fromEntity(article);
      final files = newImagePaths.map((path) => File(path)).toList();
      final updated = await _firestoreService.updateArticle(
        model,
        files,
        existingImageUrls,
      );
      return DataSuccess(updated.toEntity());
    } on Exception catch (e) {
      return DataFailed(mapFirebaseFailure(e));
    }
  }

  @override
  Future<DataState<bool>> deleteArticle(String documentId) async {
    try {
      await _firestoreService.deleteArticle(documentId);
      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataFailed(mapFirebaseFailure(e));
    }
  }

}
