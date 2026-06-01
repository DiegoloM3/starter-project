import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_related_articles_use_case.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late GetRelatedArticlesUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = GetRelatedArticlesUseCase(mockRepository);
  });

  const params = GetRelatedArticlesParams(
    categoryId: 'cat_1',
    excludeArticleId: 'art_1',
  );

  group('GetRelatedArticlesUseCase', () {
    test('should_return_DataSuccess_with_articles_when_repository_succeeds',
        () async {
      final articles = <ArticleEntity>[];
      when(() => mockRepository.getRelatedArticles('cat_1', 'art_1'))
          .thenAnswer((_) async => DataSuccess(articles));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, equals(articles));
      verify(() => mockRepository.getRelatedArticles('cat_1', 'art_1'))
          .called(1);
    });

    test('should_return_DataFailed_when_repository_throws', () async {
      final exception = Exception('error');
      when(() => mockRepository.getRelatedArticles('cat_1', 'art_1'))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, equals(exception));
    });
  });
}
