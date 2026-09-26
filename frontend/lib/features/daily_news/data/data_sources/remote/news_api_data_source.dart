import 'package:dio/dio.dart';

import '../../models/article.dart';
import '../../../../../core/constants/constants.dart';
import 'news_api_service.dart';

abstract class NewsArticlesDataSource {
  Future<List<ArticleModel>> getNewsArticles();
}

class NewsApiException implements Exception {
  final String message;
  final Object? cause;
  const NewsApiException(this.message, {this.cause});

  @override
  String toString() => message;
}

const _rateLimitedMessage =
    'The external news provider has reached its request limit. Please try again later.';
const _providerUnavailableMessage =
    'Latest news is currently unavailable from the external provider.';

class NewsApiDataSource implements NewsArticlesDataSource {
  final NewsApiService _service;
  final String _apiKey;

  const NewsApiDataSource(this._service, {String? apiKey})
      : _apiKey = apiKey ?? newsAPIKey;

  @override
  Future<List<ArticleModel>> getNewsArticles() async {
    // The configured NewsAPI plan is development-only. Fail closed when no
    // local key was explicitly provided instead of making an unauthenticated
    // request from a public client build.
    if (_apiKey.trim().isEmpty) {
      throw const NewsApiException(_providerUnavailableMessage);
    }
    try {
      final response = await _service.getNewsArticles(
        apiKey: _apiKey,
        country: countryQuery,
        category: categoryQuery,
      );
      if (response.response.statusCode == 429) {
        throw const NewsApiException(_rateLimitedMessage);
      }
      if (response.response.statusCode != 200 || response.data.status != 'ok') {
        throw NewsApiException(
          _providerUnavailableMessage,
          cause: response.response,
        );
      }
      return response.data.articles;
    } on NewsApiException {
      rethrow;
    } on DioException catch (error) {
      final message = error.response?.statusCode == 429
          ? _rateLimitedMessage
          : 'Unable to load daily news.';
      throw NewsApiException(message, cause: error);
    }
  }
}
