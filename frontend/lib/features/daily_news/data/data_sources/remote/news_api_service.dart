import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
<<<<<<< HEAD
import 'package:retrofit/retrofit.dart';
import '../../../../../core/constants/constants.dart';
import 'package:dio/dio.dart';
part 'news_api_service.g.dart';

@RestApi(baseUrl:newsAPIBaseURL)
abstract class NewsApiService {
  factory NewsApiService(Dio dio) = _NewsApiService;
  
  @GET('/top-headlines')
  Future<HttpResponse<List<ArticleModel>>> getNewsArticles({
    @Query("apiKey") String ? apiKey,
    @Query("country") String ? country,
    @Query("category") String ? category,
  });
}
=======
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
part 'news_api_service.g.dart';

@RestApi(baseUrl: kNewsApiBaseUrl)
abstract class NewsApiService {
  factory NewsApiService(Dio dio) = _NewsApiService;

  @GET('/top-headlines')
  Future<HttpResponse<List<ArticleModel>>> getNewsArticles({
    @Query('apiKey') String? apiKey,
    @Query('country') String? country,
    @Query('category') String? category,
  });
}
>>>>>>> fbce432 (Finish PR (project setup))
