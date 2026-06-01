import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';
import 'package:tortutip/features/articles/domain/use_cases/unsave_article_use_case.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late UnsaveArticleUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = UnsaveArticleUseCase(mockRepository);
  });

  group('UnsaveArticleUseCase', () {
    const params = UnsaveArticleParams(userId: 'user_1', articleId: 'article_1');

    test('should_return_DataSuccess_when_repository_succeeds', () async {
      when(() => mockRepository.unsaveArticle('user_1', 'article_1'))
          .thenAnswer((_) async => const DataSuccess(true));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<bool>>());
      expect(result.data, isTrue);
    });

    test('should_return_DataFailed_when_repository_fails', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.unsaveArticle('user_1', 'article_1'))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<bool>>());
    });
  });
}
