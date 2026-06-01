import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';
import 'package:tortutip/features/articles/domain/use_cases/save_article_use_case.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late SaveArticleUseCase useCase;
  late MockArticleRepository mockRepository;

  const params = SaveArticleParams(userId: 'user_1', articleId: 'art_1');

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = SaveArticleUseCase(mockRepository);
    registerFallbackValue(params);
  });

  group('SaveArticleUseCase', () {
    test('should_return_DataSuccess_when_repository_succeeds', () async {
      when(() => mockRepository.saveArticle(any(), any()))
          .thenAnswer((_) async => const DataSuccess(true));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<bool>>());
      expect(result.data, isTrue);
    });

    test('should_return_DataFailed_when_repository_fails', () async {
      when(() => mockRepository.saveArticle(any(), any()))
          .thenAnswer((_) async => DataFailed(Exception('error')));

      final result = await useCase(params);

      expect(result, isA<DataFailed<bool>>());
    });
  });
}
