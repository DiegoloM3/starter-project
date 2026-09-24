import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_upload_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_article.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late UploadArticleUseCase uploadArticleUseCase;
  late MockArticleRepository mockArticleRepository;

  setUpAll(() {
    registerFallbackValue(
      CreateArticleParams(
        title: 'Test',
        content: 'Test content with more than 20 characters',
        author: 'Test',
        thumbnailPath: '/path',
      ),
    );
  });

  setUp(() {
    mockArticleRepository = MockArticleRepository();
    uploadArticleUseCase = UploadArticleUseCase(mockArticleRepository);
  });

  group('UploadArticleUseCase', () {
    final testArticle = ArticleEntity(
      id: 1,
      title: 'Test Article',
      description: 'Test Description',
      urlToImage: 'https://example.com/image.jpg',
      content: 'Test content for article',
      author: 'Test Author',
    );

    test('should reject title shorter than 5 characters', () async {
      final params = CreateArticleParams(
        title: 'Bad',
        content: 'This is a valid content with more than 20 characters',
        author: 'Valid Author',
        thumbnailPath: '/path/to/image.jpg',
      );

      expect(
        () => uploadArticleUseCase(params: params),
        throwsException,
      );
    });

    test('should reject title longer than 200 characters', () async {
      final longTitle = 'a' * 201;
      final params = CreateArticleParams(
        title: longTitle,
        content: 'This is a valid content with more than 20 characters',
        author: 'Valid Author',
        thumbnailPath: '/path/to/image.jpg',
      );

      expect(
        () => uploadArticleUseCase(params: params),
        throwsException,
      );
    });

    test('should reject content shorter than 20 characters', () async {
      final params = CreateArticleParams(
        title: 'Valid Title Here',
        content: 'Short',
        author: 'Valid Author',
        thumbnailPath: '/path/to/image.jpg',
      );

      expect(
        () => uploadArticleUseCase(params: params),
        throwsException,
      );
    });

    test('should reject author shorter than 2 characters', () async {
      final params = CreateArticleParams(
        title: 'Valid Title Here',
        content: 'This is a valid content with more than 20 characters',
        author: 'A',
        thumbnailPath: '/path/to/image.jpg',
      );

      expect(
        () => uploadArticleUseCase(params: params),
        throwsException,
      );
    });

    test('should reject author longer than 100 characters', () async {
      final longAuthor = 'a' * 101;
      final params = CreateArticleParams(
        title: 'Valid Title Here',
        content: 'This is a valid content with more than 20 characters',
        author: longAuthor,
        thumbnailPath: '/path/to/image.jpg',
      );

      expect(
        () => uploadArticleUseCase(params: params),
        throwsException,
      );
    });

    test('should call repository with valid params and return success', () async {
      final params = CreateArticleParams(
        title: 'Valid Title',
        content: 'This is valid content with more than 20 characters',
        author: 'Valid Author',
        thumbnailPath: '/path/to/image.jpg',
        description: 'Test Description',
        category: 'Tech',
      );

      when(() => mockArticleRepository.uploadArticle(any()))
          .thenAnswer((_) async => DataSuccess(testArticle));

      final result = await uploadArticleUseCase(params: params);

      expect(result, isA<DataSuccess<ArticleEntity>>());
      expect((result as DataSuccess).data, equals(testArticle));
      verify(() => mockArticleRepository.uploadArticle(any())).called(1);
    });

    test('should return DataFailed when repository fails', () async {
      final params = CreateArticleParams(
        title: 'Valid Title',
        content: 'This is valid content with more than 20 characters',
        author: 'Valid Author',
        thumbnailPath: '/path/to/image.jpg',
      );

      final testError = DioError(
        requestOptions: RequestOptions(path: ''),
        error: 'Upload failed',
      );

      when(() => mockArticleRepository.uploadArticle(any()))
          .thenAnswer((_) async => DataFailed(testError));

      final result = await uploadArticleUseCase(params: params);

      expect(result, isA<DataFailed>());
    });

    test('should throw exception when params is null', () async {
      expect(
        () => uploadArticleUseCase(params: null),
        throwsException,
      );
    });
  });
}
