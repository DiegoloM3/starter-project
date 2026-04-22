import 'dart:io';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firebase_data_source.dart';

import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final FirebaseDataSource _firebaseDataSource;
  final AppDatabase _appDatabase;

  ArticleRepositoryImpl(
    this._newsApiService,
    this._firebaseDataSource,
    this._appDatabase,
  );
  
  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles({String? category}) async {
   try {
     developer.log('Solicitando artículos al backend local/remoto... Categoría: $category', name: 'SymmetryArticles');
     final httpResponse = await _newsApiService.getNewsArticles(
       apiKey: newsAPIKey,
       country: countryQuery,
       category: category ?? categoryQuery,
     );


     if (httpResponse.response.statusCode == HttpStatus.ok) {
       developer.log('Artículos recibidos con éxito (${httpResponse.data.length})', name: 'SymmetryArticles');
       return DataSuccess(httpResponse.data);
     } else {
       developer.log('Error en API local/remoto (${httpResponse.response.statusCode}), usando Firebase...', name: 'SymmetryArticles');
       return await _getFirebaseFallback();
     }
   } catch (e) {
     developer.log('Fallo total en API local/remoto: $e, usando Firebase...', name: 'SymmetryArticles');
     return await _getFirebaseFallback();
   }
  }

  Future<DataState<List<ArticleModel>>> _getFirebaseFallback() async {
    try {
      final articles = await _firebaseDataSource.getArticles();
      return DataSuccess(articles);
    } catch (e) {
      return DataFailed(DioException(
        error: "Both Local and Firebase backends are unavailable",
        requestOptions: RequestOptions(path: 'articles')
      ));
    }
  }

  @override
  Future<DataState<void>> postArticle(ArticleEntity article) async {
    final model = ArticleModel.fromEntity(article);
    try {
      developer.log('Intentando publicar artículo en API local/remoto...', name: 'SymmetryArticles');
      final httpResponse = await _newsApiService.postArticle(article: model);
      
      if (httpResponse.response.statusCode == HttpStatus.ok || httpResponse.response.statusCode == HttpStatus.created) {
        developer.log('Artículo publicado con éxito en API.', name: 'SymmetryArticles');
        return DataSuccess(null);
      } else {
        developer.log('API respondió con error: ${httpResponse.response.statusCode}. Intentando fallback...', name: 'SymmetryArticles');
        throw Exception("Local API failed with status ${httpResponse.response.statusCode}");
      }
    } catch (e) {
      developer.log('Error al publicar en API: $e. Intentando Firebase...', name: 'SymmetryArticles');
      // Fallback to Firebase
      try {
        await _firebaseDataSource.postArticle(model);
        developer.log('Artículo publicado con éxito en Firebase (Fallback).', name: 'SymmetryArticles');
        return DataSuccess(null);
      } catch (firebaseError) {
        developer.log('FALLO TOTAL: No se pudo publicar en ninguna plataforma: $firebaseError', name: 'SymmetryArticles');
        return DataFailed(DioException(
          error: "Error crítico: Fallo en API y Firebase. Revisa conexión y logs de Storage.",
          requestOptions: RequestOptions(path: 'articles')
        ));
      }
    }
  }


  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
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