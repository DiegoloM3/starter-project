import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_saved_article_ids_use_case.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late GetSavedArticleIdsUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = GetSavedArticleIdsUseCase(mockRepository);
  });

  group('GetSavedArticleIdsUseCase', () {
    const params = GetSavedArticleIdsParams(userId: 'user_1');
    final savedIds = ['article_1', 'article_2'];

    test('should_return_saved_ids_when_repository_succeeds', () async {
      when(() => mockRepository.getSavedArticleIds('user_1'))
          .thenAnswer((_) async => DataSuccess(savedIds));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<List<String>>>());
      expect(result.data, equals(savedIds));
      verify(() => mockRepository.getSavedArticleIds('user_1')).called(1);
    });

    test('should_return_failure_when_repository_fails', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.getSavedArticleIds('user_1'))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<List<String>>>());
    });
  });
}
