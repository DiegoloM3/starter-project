import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_upload_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late UpdateArticleUseCase updateArticleUseCase;
  late MockArticleRepository mockArticleRepository;

  setUpAll(() {
    registerFallbackValue(
      UpdateArticleParams(
        articleId: 'test-id',
        title: 'Test',
        content: 'Test content with more than 20 characters',
        author: 'Test',
      ),
    );
  });

  setUp(() {
    mockArticleRepository = MockArticleRepository();
    updateArticleUseCase = UpdateArticleUseCase(mockArticleRepository);
  });

  group('UpdateArticleUseCase', () {
    final testArticle = ArticleEntity(
      id: 1,
      title: 'Test Article',
      description: 'Test Description',
      urlToImage: 'https://example.com/image.jpg',
      content: 'Test content for article',
      author: 'Test Author',
    );

    test('should reject title shorter than 5 characters', () async {
      final params = UpdateArticleParams(
        articleId: 'test-id',
        title: 'Bad',
        content: 'This is a valid content with more than 20 characters',
        author: 'Valid Author',
      );

      expect(
        () => updateArticleUseCase(params: params),
        throwsException,
      );
    });

    test('should reject title longer than 200 characters', () async {
      final longTitle = 'a' * 201;
      final params = UpdateArticleParams(
        articleId: 'test-id',
        title: longTitle,
        content: 'This is a valid content with more than 20 characters',
        author: 'Valid Author',
      );

      expect(
        () => updateArticleUseCase(params: params),
        throwsException,
      );
    });

    test('should reject content shorter than 20 characters', () async {
      final params = UpdateArticleParams(
        articleId: 'test-id',
        title: 'Valid Title Here',
        content: 'Short',
        author: 'Valid Author',
      );

      expect(
        () => updateArticleUseCase(params: params),
        throwsException,
      );
    });

    test('should reject author shorter than 2 characters', () async {
      final params = UpdateArticleParams(
        articleId: 'test-id',
        title: 'Valid Title Here',
        content: 'This is a valid content with more than 20 characters',
        author: 'A',
      );

      expect(
        () => updateArticleUseCase(params: params),
        throwsException,
      );
    });

    test('should reject author longer than 100 characters', () async {
      final longAuthor = 'a' * 101;
      final params = UpdateArticleParams(
        articleId: 'test-id',
        title: 'Valid Title Here',
        content: 'This is a valid content with more than 20 characters',
        author: longAuthor,
      );

      expect(
        () => updateArticleUseCase(params: params),
        throwsException,
      );
    });

    test('should call repository with valid params and return success', () async {
      final params = UpdateArticleParams(
        articleId: 'test-id-123',
        title: 'Valid Title',
        content: 'This is valid content with more than 20 characters',
        author: 'Valid Author',
        description: 'Test Description',
        category: 'Tech',
      );

      when(() => mockArticleRepository.updateArticle(any()))
          .thenAnswer((_) async => DataSuccess(testArticle));

      final result = await updateArticleUseCase(params: params);

      expect(result, isA<DataSuccess<ArticleEntity>>());
      expect((result as DataSuccess).data, equals(testArticle));
      verify(() => mockArticleRepository.updateArticle(any())).called(1);
    });

    test('should return DataFailed when repository fails', () async {
      final params = UpdateArticleParams(
        articleId: 'test-id',
        title: 'Valid Title',
        content: 'This is valid content with more than 20 characters',
        author: 'Valid Author',
      );

      final testError = DioError(
        requestOptions: RequestOptions(path: ''),
        error: 'Update failed',
      );

      when(() => mockArticleRepository.updateArticle(any()))
          .thenAnswer((_) async => DataFailed(testError));

      final result = await updateArticleUseCase(params: params);

      expect(result, isA<DataFailed>());
    });

    test('should throw exception when params is null', () async {
      expect(
        () => updateArticleUseCase(params: null),
        throwsException,
      );
    });

    test('should accept article with optional fields', () async {
      final params = UpdateArticleParams(
        articleId: 'test-id',
        title: 'Valid Title',
        content: 'This is valid content with more than 20 characters',
        author: 'Valid Author',
        description: 'Optional Description',
        category: 'Optional Category',
        thumbnailPath: '/path/to/image.jpg',
      );

      when(() => mockArticleRepository.updateArticle(any()))
          .thenAnswer((_) async => DataSuccess(testArticle));

      final result = await updateArticleUseCase(params: params);

      expect(result, isA<DataSuccess<ArticleEntity>>());
    });
  });
}
