import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/params/update_article_params.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';
import 'package:tortutip/features/articles/domain/use_cases/update_article_use_case.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late UpdateArticleUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = UpdateArticleUseCase(mockRepository);
  });

  final params = const UpdateArticleParams(
    articleId: 'art_1',
    categoryId: 'cat_1',
    title: 'Updated Title',
    body: 'Updated body',
    coverVerticalUrl: '',
    coverHorizontalUrl: '',
    readTimeMinutes: 3,
  );

  final article = ArticleEntity(
    id: 'art_1',
    authorId: 'user_1',
    categoryId: 'cat_1',
    title: 'Updated Title',
    body: 'Updated body',
    coverVerticalUrl: '',
    coverHorizontalUrl: '',
    status: 'published',
    readTimeMinutes: 3,
    saveCount: 0,
    createdAt: DateTime(2024),
  );

  group('UpdateArticleUseCase', () {
    test('should_return_DataSuccess_when_repository_succeeds', () async {
      when(() => mockRepository.updateArticle(params))
          .thenAnswer((_) async => DataSuccess(article));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<ArticleEntity>>());
      expect(result.data, equals(article));
      verify(() => mockRepository.updateArticle(params)).called(1);
    });

    test('should_return_DataFailed_when_repository_fails', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.updateArticle(params))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<ArticleEntity>>());
      expect(result.error, equals(exception));
    });
  });
}
