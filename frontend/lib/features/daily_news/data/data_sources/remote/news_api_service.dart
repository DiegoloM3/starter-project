import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:retrofit/retrofit.dart';

class NewsApiService {
  final Dio _dio;

  NewsApiService(this._dio);

  Future<HttpResponse<List<ArticleModel>>> getNewsArticles({
    String? apiKey,
    String? country,
    String? category,
  }) async {
    try {
      final response = await _dio.get(
        'articles/',
        queryParameters: {
          'category': category,
          'limit': 20,
        },
      );


      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data is Map ? (response.data['articles'] ?? []) : []);

      final List<ArticleModel> articles =
          data.map((e) => ArticleModel.fromJson(e)).toList();

      return HttpResponse(articles, response);
    } catch (e) {
      rethrow;
    }
  }

  Future<HttpResponse<void>> postArticle({
    ArticleModel? article,
  }) async {
    try {
      final response = await _dio.post(
        'articles/',
        data: article?.toJson(),
      );

      return HttpResponse(null, response);
    } catch (e) {
      rethrow;
    }
  }
}