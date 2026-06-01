import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_feed_articles_paged_use_case.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late GetFeedArticlesPagedUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = GetFeedArticlesPagedUseCase(mockRepository);
  });

  group('GetFeedArticlesPagedUseCase', () {
    const params = GetFeedArticlesPagedParams(
      categoryIds: ['cat_1'],
      page: 0,
      pageSize: 10,
    );
    final articles = <ArticleEntity>[];

    test('should_return_articles_when_repository_succeeds_with_pagination',
        () async {
      when(() => mockRepository.getFeedArticlesPaged(['cat_1'], 0, 10))
          .thenAnswer((_) async => DataSuccess(articles));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, equals(articles));
      verify(() => mockRepository.getFeedArticlesPaged(['cat_1'], 0, 10))
          .called(1);
    });

    test('should_return_failure_when_repository_fails', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.getFeedArticlesPaged(['cat_1'], 0, 10))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
    });
  });
}
