import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/get_published_articles_params.dart';

void main() {
  test('defaults to the first page of 20 articles', () {
    const params = GetPublishedArticlesParams();

    expect(params.pageSize, 20);
    expect(params.startAfter, isNull);
  });

  test('allows up to 50 articles per page, the backend limit', () {
    expect(() => const GetPublishedArticlesParams(pageSize: GetPublishedArticlesParams.maxPageSize), returnsNormally);
  });

  test('rejects pages over the backend limit', () {
    expect(() => GetPublishedArticlesParams(pageSize: 51), throwsA(isA<AssertionError>()));
  });

  test('rejects empty pages', () {
    expect(() => GetPublishedArticlesParams(pageSize: 0), throwsA(isA<AssertionError>()));
  });
}
