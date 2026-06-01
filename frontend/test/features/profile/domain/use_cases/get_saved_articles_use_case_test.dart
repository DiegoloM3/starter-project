import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/profile/domain/repository/profile_repository.dart';
import 'package:tortutip/features/profile/domain/use_cases/get_saved_articles_use_case.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late GetSavedArticlesUseCase useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetSavedArticlesUseCase(mockRepository);
  });

  group('GetSavedArticlesUseCase', () {
    const params = GetSavedArticlesParams(userId: 'user_1', limit: 4);
    final articles = <ArticleEntity>[];

    test('should_return_articles_when_repository_succeeds', () async {
      when(() => mockRepository.getSavedArticles('user_1', 4))
          .thenAnswer((_) async => DataSuccess(articles));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, equals(articles));
      verify(() => mockRepository.getSavedArticles('user_1', 4)).called(1);
    });

    test('should_return_failure_when_repository_fails', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.getSavedArticles('user_1', 4))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, equals(exception));
    });
  });
}
