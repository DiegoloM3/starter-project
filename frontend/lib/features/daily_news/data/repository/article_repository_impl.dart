import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/errors/error_keys.dart';
import 'package:news_app_clean_architecture/core/errors/failure.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/paginated_result.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';

@LazySingleton(as: ArticleRepository)
class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;

  ArticleRepositoryImpl(this._newsApiService);

  @override
  Future<DataState<PaginatedResult<ArticleEntity>>> getNewsArticles({
    required ArticleParams params,
  }) async {
    try {
      final httpResponse = await _newsApiService
          .getNewsArticles(
            apiKey: newsAPIKey,
            country: countryQuery,
            category: categoryQuery,
            page: params.page,
            pageSize: params.pageSize,
          )
          .call;

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final paginatedResult = httpResponse.data.toEntity(
          page: params.page,
          pageSize: params.pageSize,
        );
        return DataSuccess(paginatedResult);
      } else {
        return DataFailed(
          ServerFailure(
            message: ServerErrorKeys.generic,
            statusCode: httpResponse.response.statusCode,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(
        ServerFailure(
          message: ServerErrorKeys.generic,
          statusCode: e.response?.statusCode,
        ),
      );
    }
  }
}
