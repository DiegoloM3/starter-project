import 'package:news_app_clean_architecture/features/news/data/models/news_api_response.dart';
import 'package:retrofit/retrofit.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:dio/dio.dart';

part 'news_api_service.g.dart';

/// Retrofit data source for the public news API top-headlines endpoint.
@RestApi(baseUrl: newsAPIBaseURL)
abstract class NewsApiService {
  factory NewsApiService(Dio dio, {String? baseUrl}) = _NewsApiService;

  @GET('/top-headlines')
  /// Fetches top headlines for [country]/[category] using [apiKey].
  Future<HttpResponse<NewsApiResponse>> getNewsArticles({
    @Query('apiKey') String? apiKey,
    @Query('country') String? country,
    @Query('category') String? category,
  });
}
