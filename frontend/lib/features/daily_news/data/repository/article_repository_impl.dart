import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/saved_articles_service.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/page_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final SavedArticlesService _savedArticlesService;
  final FirebaseAuth _firebaseAuth;

  ArticleRepositoryImpl(
    this._newsApiService,
    this._savedArticlesService,
    this._firebaseAuth,
  );

  // /everything supports historical pagination (~30 days back, max 100 results
  // per query), unlike /top-headlines which is a finite "now" snapshot.
  // The `q` keyword is what segments general news from fitness news.
  static const _generalNewsQuery = 'news OR breaking OR world OR business';
  static const _fitnessNewsQuery =
      'fitness OR workout OR nutrition OR wellness OR exercise OR health';

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles({
    PageParams params = const PageParams(),
  }) {
    return _fetchArticles(
      query: _generalNewsQuery,
      label: 'getNewsArticles',
      params: params,
    );
  }

  @override
  Future<DataState<List<ArticleEntity>>> getFitnessNewsArticles({
    PageParams params = const PageParams(),
  }) {
    return _fetchArticles(
      query: _fitnessNewsQuery,
      label: 'getFitnessNewsArticles',
      params: params,
    );
  }

  Future<DataState<List<ArticleEntity>>> _fetchArticles({
    required String query,
    required String label,
    required PageParams params,
  }) async {
    try {
      final httpResponse = await _newsApiService.searchEverything(
        apiKey: newsAPIKey,
        q: query,
        language: 'en',
        sortBy: 'publishedAt',
        page: params.page,
        pageSize: params.pageSize,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final entities =
            httpResponse.data.map((model) => model.toEntity()).toList();
        return DataSuccess(entities);
      } else {
        return DataFailed(NetworkException(
          message: httpResponse.response.statusMessage ?? 'HTTP error',
          code: httpResponse.response.statusCode?.toString(),
        ));
      }
    } on DioError catch (e) {
      return DataFailed(NetworkException(
        message: e.message,
        cause: e,
        code: e.response?.statusCode?.toString(),
      ));
    } on Object catch (e, st) {
      return DataFailed(UnknownException(
        message: 'Unexpected error in $label',
        cause: e,
        stackTrace: st,
      ));
    }
  }

  // Defensive: bootstrap signs in anonymously, so currentUser is normally
  // non-null. Surfacing AuthException early beats a downstream Firestore
  // permission-denied that hides the real cause.
  String _requireUid() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException(
        message: 'Sign-in required to manage saved articles.',
        code: 'unauthenticated',
      );
    }
    return user.uid;
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() {
    return _savedArticlesService.getSavedArticles(_requireUid());
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _savedArticlesService.removeArticle(_requireUid(), article);
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _savedArticlesService.saveArticle(_requireUid(), article);
  }

  @override
  Future<bool> isArticleSaved(ArticleEntity article) {
    return _savedArticlesService.isSaved(_requireUid(), article);
  }
}
