import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/search/domain/params/search_articles_params.dart';
import 'package:tortutip/features/search/domain/repository/search_repository.dart';
import 'package:tortutip/features/search/domain/use_cases/search_articles_use_case.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late SearchArticlesUseCase useCase;
  late MockSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchRepository();
    useCase = SearchArticlesUseCase(mockRepository);
  });

  group('SearchArticlesUseCase', () {
    final params =
        const SearchArticlesParams(query: 'nutrition', limit: 20);
    final articles = <ArticleEntity>[];

    test('should_return_DataSuccess_with_articles_when_repository_succeeds',
        () async {
      when(() => mockRepository.searchArticles(params.query))
          .thenAnswer((_) async => DataSuccess(articles));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, equals(articles));
    });

    test('should_return_DataFailed_when_repository_fails', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.searchArticles(params.query))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, equals(exception));
    });

    test('should_call_repository_with_correct_params', () async {
      when(() => mockRepository.searchArticles(params.query))
          .thenAnswer((_) async => DataSuccess(articles));

      await useCase(params);

      verify(() => mockRepository.searchArticles(params.query))
          .called(1);
    });
  });
}
