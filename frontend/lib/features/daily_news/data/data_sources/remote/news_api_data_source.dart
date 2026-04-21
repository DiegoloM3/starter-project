import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/exceptions/article_exceptions.dart';

import '../../../../../core/constants/constants.dart';

class NewsApiDataSource {
  final NewsApiService _service;

  NewsApiDataSource(this._service);

  Future<List<ArticleModel>> getTopHeadlines() async {
    try {
      final response = await _service.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );
      final status = response.response.statusCode ?? 0;
      if (status == 200) return response.data;
      throw ArticleFetchException(
          response.response.statusMessage ?? 'Failed to fetch articles.');
    } on DioError catch (e) {
      throw ArticleFetchException(e.message);
    }
  }
}
