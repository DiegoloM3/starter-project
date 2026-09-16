import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article_model.dart';

/// Remote data source for the news provider.
///
/// Converts raw JSON into [ArticleModel]s and lets [DioException]s propagate;
/// the repository decides how failures surface to the domain.
class NewsApiService {
  final Dio _dio;

  NewsApiService(this._dio);

  static const String _topHeadlinesPath = '/top-headlines';
  static const String _everythingPath = '/everything';
  static const String _articlesKey = 'articles';
  static const int _searchPageSize = 30;

  /// The provider requires a country for top headlines. The app is
  /// US/English-only by design, so it is fixed to [countryQuery] here and
  /// never reaches the domain.
  Future<List<ArticleModel>> getTopHeadlines({required String category}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$newsAPIBaseURL$_topHeadlinesPath',
      queryParameters: {
        'apiKey': newsAPIKey,
        'country': countryQuery,
        'category': category,
      },
    );
    return _parseArticles(response.data);
  }

  Future<List<ArticleModel>> searchArticles(String query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$newsAPIBaseURL$_everythingPath',
      queryParameters: {
        'apiKey': newsAPIKey,
        'q': query,
        'sortBy': 'publishedAt',
        'pageSize': _searchPageSize,
      },
    );
    return _parseArticles(response.data);
  }

  List<ArticleModel> _parseArticles(Map<String, dynamic>? body) {
    final rawArticles = body?[_articlesKey];
    if (rawArticles is! List) {
      return const [];
    }
    return rawArticles
        .whereType<Map<String, dynamic>>()
        .map(ArticleModel.fromRawData)
        .toList();
  }
}
