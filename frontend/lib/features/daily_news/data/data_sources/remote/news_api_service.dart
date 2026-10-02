import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import '../../../../../core/constants/constants.dart';

class NewsApiService {
  final Dio _dio;

  NewsApiService(this._dio);

  /// Throws a [DioException] if the request fails or NewsAPI answers with an error status.
  Future<List<ArticleModel>> getNewsArticles({
    String? apiKey,
    String? country,
    String? category,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$newsAPIBaseURL/top-headlines',
      queryParameters: {'apiKey': apiKey, 'country': country, 'category': category}
        ..removeWhere((_, value) => value == null),
    );
    final articles = response.data!['articles'] as List<dynamic>;
    return articles
        .map((article) => ArticleModel.fromRawData(article as Map<String, dynamic>))
        .toList();
  }
}
