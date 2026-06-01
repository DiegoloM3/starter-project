import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/explore/domain/repository/explore_repository.dart';
import 'package:tortutip/features/explore/domain/use_cases/get_articles_by_category_use_case.dart';

class MockExploreRepository extends Mock implements ExploreRepository {}

void main() {
  late GetArticlesByCategoryUseCase useCase;
  late MockExploreRepository mockRepository;

  setUp(() {
    mockRepository = MockExploreRepository();
    useCase = GetArticlesByCategoryUseCase(mockRepository);
  });

  group('GetArticlesByCategoryUseCase', () {
    const params = GetArticlesByCategoryParams(
      categoryId: 'cat_1',
      page: 0,
      pageSize: 10,
    );
    final articles = <ArticleEntity>[];

    test('should_return_DataSuccess_with_articles_when_repository_succeeds',
        () async {
      when(() => mockRepository.getArticlesByCategory('cat_1', 0, 10))
          .thenAnswer((_) async => DataSuccess(articles));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, equals(articles));
      verify(() => mockRepository.getArticlesByCategory('cat_1', 0, 10))
          .called(1);
    });

    test('should_return_DataFailed_when_repository_fails', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.getArticlesByCategory('cat_1', 0, 10))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, equals(exception));
    });
  });
}
