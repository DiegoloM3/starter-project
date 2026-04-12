import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_interceptor.dart';

void main() {
  late NewsApiInterceptor interceptor;

  setUp(() {
    interceptor = NewsApiInterceptor();
  });

  group('NewsApiInterceptor', () {
    test('extracts articles array from News API response envelope', () {
      final articles = [
        {'title': 'Article 1'},
        {'title': 'Article 2'},
      ];
      final Response<dynamic> response = Response(
        requestOptions: RequestOptions(),
        data: <String, dynamic>{
          'status': 'ok',
          'totalResults': 2,
          'articles': articles,
        },
      );

      interceptor.onResponse(
        response,
        ResponseInterceptorHandler(),
      );

      expect(response.data, equals(articles));
    });

    test('passes through response that is already a list', () {
      final articles = [
        {'title': 'Article 1'},
      ];
      final Response<dynamic> response = Response(
        requestOptions: RequestOptions(),
        data: articles,
      );

      interceptor.onResponse(
        response,
        ResponseInterceptorHandler(),
      );

      expect(response.data, equals(articles));
    });

    test('passes through map response without articles key', () {
      final data = <String, dynamic>{'status': 'ok', 'results': []};
      final Response<dynamic> response = Response(
        requestOptions: RequestOptions(),
        data: data,
      );

      interceptor.onResponse(
        response,
        ResponseInterceptorHandler(),
      );

      expect(response.data, equals(data));
    });
  });
}
