import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/data/datasources/remote/article_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/articles/domain/failures/article_failure.dart';
import 'package:news_app_clean_architecture/features/articles/domain/repositories/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource _remoteDataSource;

  ArticleRepositoryImpl(this._remoteDataSource);

  @override
  Future<DataState<List<ArticleEntity>>> getArticles({
    String? category,
  }) async {
    try {
      final articles = await _remoteDataSource.getArticles(category: category);
      return DataSuccess(articles);
    } catch (e) {
      return DataFailed(_toDataError(e));
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getMyArticles(
    String authorId, {
    String? status,
  }) async {
    try {
      final articles = await _remoteDataSource.getMyArticles(
        authorId,
        status: status,
      );
      return DataSuccess(articles);
    } catch (e) {
      return DataFailed(_toDataError(e));
    }
  }

  @override
  Future<DataState<ArticleEntity>> getArticleById(String id) async {
    try {
      final article = await _remoteDataSource.getArticleById(id);
      return DataSuccess(article);
    } catch (e) {
      return DataFailed(_toDataError(e));
    }
  }

  @override
  Future<DataState<ArticleEntity>> createArticle(
    ArticleEntity article, {
    File? thumbnail,
  }) async {
    try {
      final created = await _remoteDataSource.createArticle(
        article,
        thumbnail: thumbnail,
      );
      return DataSuccess(created);
    } catch (e) {
      return DataFailed(_toDataError(e));
    }
  }

  @override
  Future<DataState<ArticleEntity>> updateArticle(
    ArticleEntity article, {
    File? thumbnail,
  }) async {
    try {
      final updated = await _remoteDataSource.updateArticle(
        article,
        thumbnail: thumbnail,
      );
      return DataSuccess(updated);
    } catch (e) {
      return DataFailed(_toDataError(e));
    }
  }

  @override
  Future<DataState<void>> deleteArticle(String id) async {
    try {
      await _remoteDataSource.deleteArticle(id);
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(_toDataError(e));
    }
  }

  DioError _toDataError(Object e) {
    final failure = e is FirebaseException
        ? ArticleFailure(_mapFirebaseCode(e.code))
        : const ArticleFailure('Something went wrong. Please try again.');
    return DioError(
      requestOptions: RequestOptions(path: ''),
      error: failure,
    );
  }

  String _mapFirebaseCode(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'not-found':
        return 'Article not found.';
      case 'unavailable':
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
