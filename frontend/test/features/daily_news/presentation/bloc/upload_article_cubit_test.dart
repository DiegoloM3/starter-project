import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_upload_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/upload_article/upload_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/upload_article/upload_article_state.dart';

class MockUploadArticleUseCase extends Mock implements UploadArticleUseCase {}

void main() {
  late UploadArticleCubit uploadArticleCubit;
  late MockUploadArticleUseCase mockUploadArticleUseCase;

  setUp(() {
    mockUploadArticleUseCase = MockUploadArticleUseCase();
    uploadArticleCubit = UploadArticleCubit(
      uploadArticleUseCase: mockUploadArticleUseCase,
    );
  });

  tearDown(() => uploadArticleCubit.close());

  group('UploadArticleCubit', () {
    final testArticle = const ArticleEntity(
      id: 1,
      title: 'Test Article',
      description: 'Test Description',
      urlToImage: 'https://example.com/image.jpg',
      content: 'Test content for article',
      author: 'Test Author',
    );

    test('initial state is UploadArticleInitial', () {
      expect(uploadArticleCubit.state, isA<UploadArticleInitial>());
    });

    test('emits Loading then Success when upload succeeds', () async {
      when(() => mockUploadArticleUseCase(params: any(named: 'params')))
          .thenAnswer((_) async => DataSuccess(testArticle));

      expectLater(
        uploadArticleCubit.stream,
        emitsInOrder([
          isA<UploadArticleLoading>(),
          isA<UploadArticleSuccess>(),
        ]),
      );

      await uploadArticleCubit.uploadArticle(
        title: 'Test Title',
        content: 'This is valid content with more than 20 characters',
        author: 'Test Author',
        thumbnailPath: '/path/to/image.jpg',
      );
    });

    test('emits Loading then Failure when upload fails', () async {
      final testError = DioError(
        requestOptions: RequestOptions(path: ''),
        error: 'Upload failed',
      );
      when(() => mockUploadArticleUseCase(params: any(named: 'params')))
          .thenAnswer((_) async => DataFailed(testError));

      expectLater(
        uploadArticleCubit.stream,
        emitsInOrder([
          isA<UploadArticleLoading>(),
          isA<UploadArticleFailure>(),
        ]),
      );

      await uploadArticleCubit.uploadArticle(
        title: 'Test Title',
        content: 'This is valid content with more than 20 characters',
        author: 'Test Author',
        thumbnailPath: '/path/to/image.jpg',
      );
    });

    test('emits Loading then Failure on exception', () async {
      when(() => mockUploadArticleUseCase(params: any(named: 'params')))
          .thenThrow(Exception('Network error'));

      expectLater(
        uploadArticleCubit.stream,
        emitsInOrder([
          isA<UploadArticleLoading>(),
          isA<UploadArticleFailure>(),
        ]),
      );

      await uploadArticleCubit.uploadArticle(
        title: 'Test Title',
        content: 'This is valid content with more than 20 characters',
        author: 'Test Author',
        thumbnailPath: '/path/to/image.jpg',
      );
    });

    test('resetState emits UploadArticleInitial', () {
      uploadArticleCubit.resetState();
      expect(uploadArticleCubit.state, isA<UploadArticleInitial>());
    });
  });
}
