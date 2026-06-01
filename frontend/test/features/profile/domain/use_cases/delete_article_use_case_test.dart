import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/profile/domain/repository/profile_repository.dart';
import 'package:tortutip/features/profile/domain/use_cases/delete_article_use_case.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late DeleteArticleUseCase useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = DeleteArticleUseCase(mockRepository);
  });

  group('DeleteArticleUseCase', () {
    const params =
        DeleteArticleParams(articleId: 'article_1', userId: 'user_1');

    test('should_return_true_when_delete_succeeds', () async {
      when(() => mockRepository.deleteArticle('article_1', 'user_1'))
          .thenAnswer((_) async => const DataSuccess(true));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<bool>>());
      expect(result.data, isTrue);
      verify(() => mockRepository.deleteArticle('article_1', 'user_1'))
          .called(1);
    });

    test('should_return_failure_when_delete_fails', () async {
      final exception = Exception('No autorizado');
      when(() => mockRepository.deleteArticle('article_1', 'user_1'))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<bool>>());
      expect(result.error, equals(exception));
    });
  });
}
