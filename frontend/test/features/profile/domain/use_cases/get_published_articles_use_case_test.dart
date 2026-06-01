import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/profile/domain/repository/profile_repository.dart';
import 'package:tortutip/features/profile/domain/use_cases/get_published_articles_use_case.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late GetPublishedArticlesUseCase useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetPublishedArticlesUseCase(mockRepository);
  });

  group('GetPublishedArticlesUseCase', () {
    const params =
        GetPublishedArticlesParams(authorId: 'author_1', limit: 5);
    final articles = <ArticleEntity>[];

    test('should_return_published_articles_when_repository_succeeds',
        () async {
      when(() => mockRepository.getPublishedArticles('author_1', 5))
          .thenAnswer((_) async => DataSuccess(articles));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, equals(articles));
      verify(() => mockRepository.getPublishedArticles('author_1', 5))
          .called(1);
    });

    test('should_return_failure_when_repository_fails', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.getPublishedArticles('author_1', 5))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, equals(exception));
    });
  });
}
