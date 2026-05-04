import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/search/data/data_sources/remote/article_search_service.dart';
import 'package:news_app_clean_architecture/features/search/data/repository/search_repository_impl.dart';
import 'package:news_app_clean_architecture/features/search/domain/params/semantic_search_params.dart';

class MockArticleSearchService extends Mock implements ArticleSearchService {}

void main() {
  late MockArticleSearchService service;
  late SearchRepositoryImpl repo;

  setUp(() {
    service = MockArticleSearchService();
    repo = SearchRepositoryImpl(service);
  });

  test('returns DataSuccess with article IDs on happy path', () async {
    when(() => service.searchArticles(any(), limit: any(named: 'limit')))
        .thenAnswer((_) async => ['a-1', 'a-2']);

    final result =
        await repo.searchArticles(const SemanticSearchParams(query: 'q'));

    expect(result, isA<DataSuccess<List<String>>>());
    expect(result.data, equals(['a-1', 'a-2']));
  });

  test('returns DataFailed when service throws AppException', () async {
    when(() => service.searchArticles(any(), limit: any(named: 'limit')))
        .thenThrow(const AuthException(
      message: 'sign in',
      code: 'unauthenticated',
    ));

    final result =
        await repo.searchArticles(const SemanticSearchParams(query: 'q'));

    expect(result, isA<DataFailed<List<String>>>());
    expect(result.error, isA<AuthException>());
  });

  test('returns DataFailed with UnknownException on unexpected error',
      () async {
    when(() => service.searchArticles(any(), limit: any(named: 'limit')))
        .thenThrow(Exception('something else'));

    final result =
        await repo.searchArticles(const SemanticSearchParams(query: 'q'));

    expect(result, isA<DataFailed<List<String>>>());
    expect(result.error, isA<UnknownException>());
  });
}
