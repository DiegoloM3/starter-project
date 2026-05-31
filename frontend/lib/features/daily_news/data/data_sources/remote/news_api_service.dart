import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/models/common.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/models/top_headlines.dart';
import 'package:retrofit/retrofit.dart';

import 'news_api_client.dart';

@lazySingleton
class NewsApiService {
  final NewsApiClient _client;

  const NewsApiService(this._client);

  Cancellable<HttpResponse<TopHeadlinesModel>> getNewsArticles({
    String? apiKey,
    String? country,
    String? category,
    int? page,
    int? pageSize,
  }) {
    final cancelToken = CancelToken();
    final call = _client.getNewsArticles(
      apiKey: apiKey,
      country: country,
      category: category,
      page: page,
      pageSize: pageSize,
      cancelToken: cancelToken,
    );
    return Cancellable(call, cancelToken);
  }
}
