import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../../core/constants/constants.dart';
import 'models/top_headlines.dart';

part 'news_api_client.g.dart';

@RestApi(baseUrl: newsAPIBaseURL)
abstract class NewsApiClient {
  factory NewsApiClient(Dio dio) = _NewsApiClient;

  @GET('/top-headlines')
  Future<HttpResponse<TopHeadlinesModel>> getNewsArticles({
    @Query("apiKey") String? apiKey,
    @Query("country") String? country,
    @Query("category") String? category,
    @Query("page") int? page,
    @Query("pageSize") int? pageSize,
    @CancelRequest() CancelToken? cancelToken,
  });
}
