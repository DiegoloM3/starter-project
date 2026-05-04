import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
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
    @Query("page") int ? page,
    @Query("pageSize") int ? pageSize,
  });

  @GET('/everything')
  Future<HttpResponse<List<ArticleModel>>> searchEverything({
    @Query("apiKey") String ? apiKey,
    @Query("q") String ? q,
    @Query("language") String ? language,
    @Query("sortBy") String ? sortBy,
    @Query("page") int ? page,
    @Query("pageSize") int ? pageSize,
  });
}