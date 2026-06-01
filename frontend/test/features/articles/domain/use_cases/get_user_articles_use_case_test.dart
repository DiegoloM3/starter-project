import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_user_articles_use_case.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late GetUserArticlesUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = GetUserArticlesUseCase(mockRepository);
  });

  group('GetUserArticlesUseCase', () {
    final articles = <ArticleEntity>[];

    test('should_return_DataSuccess_when_repository_succeeds', () async {
      when(() => mockRepository.getUserArticles('user_1'))
          .thenAnswer((_) async => DataSuccess(articles));

      final result = await useCase('user_1');

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
    });

    test('should_return_DataFailed_when_repository_fails', () async {
      when(() => mockRepository.getUserArticles('user_1'))
          .thenAnswer((_) async => DataFailed(Exception('error')));

      final result = await useCase('user_1');

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
    });
  });
}
