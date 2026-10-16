import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../core/constants/constants.dart';
import '../../models/article.dart';
import 'news_api_service.dart';

/// Gets the top headlines from the news API and throws when the API does not
/// answer successfully, so the repository does not depend on the HTTP client.
class NewsHeadlinesService {
  final NewsApiService _newsApiService;

  NewsHeadlinesService(this._newsApiService);

  Future<List<ArticleModel>> getTopHeadlines() async {
    final httpResponse = await _newsApiService.getNewsArticles(
      apiKey: newsAPIKey,
      country: countryQuery,
      category: categoryQuery,
    );
    if (httpResponse.response.statusCode != HttpStatus.ok) {
      throw DioError(
        error: httpResponse.response.statusMessage,
        response: httpResponse.response,
        type: DioErrorType.response,
        requestOptions: httpResponse.response.requestOptions,
      );
    }
    return httpResponse.data;
  }
}
