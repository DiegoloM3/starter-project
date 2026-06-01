import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_feed_articles_use_case.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late GetFeedArticlesUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = GetFeedArticlesUseCase(mockRepository);
  });

  group('GetFeedArticlesUseCase', () {
    final categoryIds = ['cat_1', 'cat_2'];
    final articles = <ArticleEntity>[];

    test('should_return_DataSuccess_when_repository_succeeds', () async {
      when(() => mockRepository.getFeedArticles(categoryIds))
          .thenAnswer((_) async => DataSuccess(articles));

      final result = await useCase(categoryIds);

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, equals(articles));
    });

    test('should_return_DataFailed_when_repository_fails', () async {
      when(() => mockRepository.getFeedArticles(categoryIds))
          .thenAnswer((_) async => DataFailed(Exception('error')));

      final result = await useCase(categoryIds);

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
    });
  });
}
