import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/params/publish_article_params.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';
import 'package:tortutip/features/articles/domain/use_cases/publish_article_use_case.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late PublishArticleUseCase useCase;
  late MockArticleRepository mockRepository;

  const params = PublishArticleParams(
    authorId: 'user_1',
    categoryId: 'cat_1',
    title: 'Title',
    body: 'Body',
    coverVerticalUrl: '',
    coverHorizontalUrl: '',
  );

  final article = ArticleEntity(
    id: 'art_1',
    authorId: 'user_1',
    categoryId: 'cat_1',
    title: 'Title',
    body: 'Body',
    coverVerticalUrl: '',
    coverHorizontalUrl: '',
    status: 'published',
    readTimeMinutes: 2,
    saveCount: 0,
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = PublishArticleUseCase(mockRepository);
    registerFallbackValue(params);
  });

  group('PublishArticleUseCase', () {
    test('should_return_DataSuccess_when_repository_succeeds', () async {
      when(() => mockRepository.publishArticle(any()))
          .thenAnswer((_) async => DataSuccess(article));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<ArticleEntity>>());
    });

    test('should_return_DataFailed_when_repository_fails', () async {
      when(() => mockRepository.publishArticle(any()))
          .thenAnswer((_) async => DataFailed(Exception('error')));

      final result = await useCase(params);

      expect(result, isA<DataFailed<ArticleEntity>>());
    });
  });
}
