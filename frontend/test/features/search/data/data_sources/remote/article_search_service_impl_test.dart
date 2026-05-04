import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/search/data/data_sources/remote/article_search_service_impl.dart';

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<Object?> {}

void main() {
  late MockFirebaseFunctions functions;
  late MockHttpsCallable callable;
  late ArticleSearchServiceImpl service;

  setUp(() {
    functions = MockFirebaseFunctions();
    callable = MockHttpsCallable();
    when(() => functions.httpsCallable('searchArticles'))
        .thenReturn(callable);
    service = ArticleSearchServiceImpl(functions);
  });

  group('ArticleSearchServiceImpl.searchArticles', () {
    test('returns ordered article IDs on success', () async {
      final result = MockHttpsCallableResult();
      when(() => result.data).thenReturn({
        'results': [
          {'articleId': 'a-1', 'distance': 0.1},
          {'articleId': 'a-2', 'distance': 0.2},
        ],
      });
      when(() => callable.call(any())).thenAnswer((_) async => result);

      final ids = await service.searchArticles('marathon', limit: 10);

      expect(ids, equals(['a-1', 'a-2']));
      final captured = verify(() => callable.call(captureAny())).captured.single;
      expect(captured, equals({'query': 'marathon', 'limit': 10}));
    });

    test('returns empty list when results is empty', () async {
      final result = MockHttpsCallableResult();
      when(() => result.data).thenReturn({'results': []});
      when(() => callable.call(any())).thenAnswer((_) async => result);

      final ids = await service.searchArticles('nothing', limit: 5);

      expect(ids, isEmpty);
    });

    test('maps unauthenticated FirebaseFunctionsException to AuthException',
        () async {
      when(() => callable.call(any())).thenThrow(
        FirebaseFunctionsException(message: 'sign in', code: 'unauthenticated'),
      );

      expect(
        () => service.searchArticles('q', limit: 10),
        throwsA(isA<AuthException>()
            .having((e) => e.code, 'code', 'unauthenticated')),
      );
    });

    test('maps resource-exhausted to NetworkException with rate-limit code',
        () async {
      when(() => callable.call(any())).thenThrow(
        FirebaseFunctionsException(
            message: 'too many', code: 'resource-exhausted'),
      );

      expect(
        () => service.searchArticles('q', limit: 10),
        throwsA(isA<NetworkException>()
            .having((e) => e.code, 'code', 'rate-limit')),
      );
    });

    test('maps invalid-argument to ValidationException', () async {
      when(() => callable.call(any())).thenThrow(
        FirebaseFunctionsException(
            message: 'bad input', code: 'invalid-argument'),
      );

      expect(
        () => service.searchArticles('q', limit: 10),
        throwsA(isA<ValidationException>()),
      );
    });

    test('maps unknown FirebaseFunctionsException to NetworkException',
        () async {
      when(() => callable.call(any())).thenThrow(
        FirebaseFunctionsException(message: 'oops', code: 'internal'),
      );

      expect(
        () => service.searchArticles('q', limit: 10),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
