import 'package:dio/dio.dart';

/// Extracts the `articles` array from the News API response envelope.
///
/// The News API returns `{"status":"ok","totalResults":N,"articles":[...]}`,
/// but the Retrofit-generated service expects a raw JSON array.
/// This interceptor unwraps the response so Retrofit receives `[...]` directly.
class NewsApiInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('articles')) {
      response.data = data['articles'];
    }
    handler.next(response);
  }
}
