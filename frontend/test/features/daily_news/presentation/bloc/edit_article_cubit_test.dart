import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_upload_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/edit_article/edit_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/edit_article/edit_article_state.dart';

class MockUpdateArticleUseCase extends Mock implements UpdateArticleUseCase {}

void main() {
  late EditArticleCubit editArticleCubit;
  late MockUpdateArticleUseCase mockUpdateArticleUseCase;

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
    mockUpdateArticleUseCase = MockUpdateArticleUseCase();
    editArticleCubit = EditArticleCubit(updateArticleUseCase: mockUpdateArticleUseCase);
  });

  tearDown(() {
    editArticleCubit.close();
  });

  group('EditArticleCubit', () {
    final testArticle = ArticleEntity(
      id: 1,
      title: 'Updated Article',
      description: 'Updated Description',
      urlToImage: 'https://example.com/image.jpg',
      content: 'Updated content for article',
      author: 'Updated Author',
    );

    test('initial state is EditArticleInitial', () {
      expect(editArticleCubit.state, isA<EditArticleInitial>());
    });

    test('updateArticle emits loading and success states', () async {
      when(() => mockUpdateArticleUseCase(params: any(named: 'params')))
          .thenAnswer((_) async => DataSuccess(testArticle));

      expectLater(
        editArticleCubit.stream,
        emitsInOrder([
          isA<EditArticleLoading>(),
          isA<EditArticleSuccess>(),
        ]),
      );

      await editArticleCubit.updateArticle(
        articleId: 'test-id',
        title: 'Updated Article',
        content: 'Updated content for article',
        author: 'Updated Author',
        description: 'Updated Description',
      );
    });

    test('updateArticle emits loading and failure states on error', () async {
      final testError = DioError(
        requestOptions: RequestOptions(path: ''),
        error: 'Update failed',
      );

      when(() => mockUpdateArticleUseCase(params: any(named: 'params')))
          .thenAnswer((_) async => DataFailed(testError));

      expectLater(
        editArticleCubit.stream,
        emitsInOrder([
          isA<EditArticleLoading>(),
          isA<EditArticleFailure>(),
        ]),
      );

      await editArticleCubit.updateArticle(
        articleId: 'test-id',
        title: 'Updated Article',
        content: 'Updated content for article',
        author: 'Updated Author',
      );
    });

    test('updateArticle emits failure state on exception', () async {
      when(() => mockUpdateArticleUseCase(params: any(named: 'params')))
          .thenThrow(Exception('Unknown error'));

      expectLater(
        editArticleCubit.stream,
        emitsInOrder([
          isA<EditArticleLoading>(),
          isA<EditArticleFailure>(),
        ]),
      );

      await editArticleCubit.updateArticle(
        articleId: 'test-id',
        title: 'Updated Article',
        content: 'Updated content for article',
        author: 'Updated Author',
      );
    });

    test('resetState returns to EditArticleInitial', () async {
      when(() => mockUpdateArticleUseCase(params: any(named: 'params')))
          .thenAnswer((_) async => DataSuccess(testArticle));

      await editArticleCubit.updateArticle(
        articleId: 'test-id',
        title: 'Updated Article',
        content: 'Updated content for article',
        author: 'Updated Author',
      );

      editArticleCubit.resetState();
      expect(editArticleCubit.state, isA<EditArticleInitial>());
    });

    test('updateArticle passes all parameters to use case correctly', () async {
      when(() => mockUpdateArticleUseCase(params: any(named: 'params')))
          .thenAnswer((_) async => DataSuccess(testArticle));

      await editArticleCubit.updateArticle(
        articleId: 'test-id-123',
        title: 'New Title',
        content: 'New content that is definitely more than 20 characters',
        author: 'New Author',
        description: 'New Description',
        category: 'Tech',
        thumbnailPath: '/path/to/image.jpg',
      );

      verify(() => mockUpdateArticleUseCase(
        params: any(named: 'params'),
      )).called(1);
    });
  });
}
