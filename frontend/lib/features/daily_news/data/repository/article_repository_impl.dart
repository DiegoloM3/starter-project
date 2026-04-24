import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  ArticleRepositoryImpl(this._newsApiService, this._appDatabase);
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;

  @override
  Future<Either<AppFailure, List<ArticleEntity>>> getNewsArticles() {
    return _guardNetwork(() async {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final articles = httpResponse.data.map((m) => m.toEntity()).toList();
        return Right(articles);
      }
      return Left(
        AppFailure.network(
          message: httpResponse.response.statusMessage,
          statusCode: httpResponse.response.statusCode,
        ),
      );
    });
  }

  @override
  Future<Either<AppFailure, List<ArticleEntity>>> getSavedArticles() {
    return _guardCache(() async {
      final models = await _appDatabase.articleDAO.getArticles();
      return Right(models.map((m) => m.toEntity()).toList());
    });
  }

  @override
  Future<Either<AppFailure, Unit>> removeArticle(ArticleEntity article) {
    return _guardCache(() async {
      await _appDatabase.articleDAO.deleteArticle(
        ArticleModel.fromEntity(article),
      );
      return const Right(unit);
    });
  }

  @override
  Future<Either<AppFailure, Unit>> saveArticle(ArticleEntity article) {
    return _guardCache(() async {
      await _appDatabase.articleDAO.insertArticle(
        ArticleModel.fromEntity(article),
      );
      return const Right(unit);
    });
  }

  /// Runs [action] translating network/IO failures into [AppFailure.network]
  /// and anything else into [AppFailure.unknown]. Keeps each method free of
  /// boilerplate try/catch blocks.
  Future<Either<AppFailure, T>> _guardNetwork<T>(
    Future<Either<AppFailure, T>> Function() action,
  ) async {
    try {
      return await action();
    } on Exception catch (e) {
      return Left(AppFailure.network(message: e.toString()));
    } catch (e, s) {
      return Left(AppFailure.unknown(cause: e, stackTrace: s));
    }
  }

  Future<Either<AppFailure, T>> _guardCache<T>(
    Future<Either<AppFailure, T>> Function() action,
  ) async {
    try {
      return await action();
    } catch (e) {
      return Left(AppFailure.cache(message: e.toString()));
    }
  }
}
