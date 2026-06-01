import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_article_detail_use_case.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late GetArticleDetailUseCase useCase;
  late MockArticleRepository mockRepository;

  final article = ArticleEntity(
    id: 'art_1',
    authorId: 'user_1',
    categoryId: 'cat_1',
    title: 'Test',
    body: 'Body',
    coverVerticalUrl: '',
    coverHorizontalUrl: '',
    status: 'published',
    readTimeMinutes: 3,
    saveCount: 0,
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = GetArticleDetailUseCase(mockRepository);
  });

  group('GetArticleDetailUseCase', () {
    test('should_return_DataSuccess_when_repository_succeeds', () async {
      when(() => mockRepository.getArticleDetail('art_1'))
          .thenAnswer((_) async => DataSuccess(article));

      final result = await useCase('art_1');

      expect(result, isA<DataSuccess<ArticleEntity>>());
      expect(result.data, equals(article));
    });

    test('should_return_DataFailed_when_repository_fails', () async {
      when(() => mockRepository.getArticleDetail('art_1'))
          .thenAnswer((_) async => DataFailed(Exception('not found')));

      final result = await useCase('art_1');

      expect(result, isA<DataFailed<ArticleEntity>>());
    });
  });
}
