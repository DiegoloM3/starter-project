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
  Future<Either<AppFailure, List<ArticleEntity>>> getNewsArticles() async {
    try {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return Right(httpResponse.data);
      }
      return Left(
        AppFailure.network(
          message: httpResponse.response.statusMessage,
          statusCode: httpResponse.response.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left(AppFailure.network(message: e.toString()));
    } catch (e, s) {
      return Left(AppFailure.unknown(cause: e, stackTrace: s));
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.deleteArticle(
      ArticleModel.fromEntity(article),
    );
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.insertArticle(
      ArticleModel.fromEntity(article),
    );
  }
}
