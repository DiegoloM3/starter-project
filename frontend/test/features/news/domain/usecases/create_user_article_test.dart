import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/create_user_article.dart';

import 'create_user_article_test.mocks.dart';

@GenerateMocks([UserArticleRepository])
void main() {
  late MockUserArticleRepository mockRepository;
  late CreateUserArticle usecase;

  const tArticle = ArticleEntity(
    id: '1',
    authorDisplayName: 'John Doe',
    title: 'Test Title',
    urlToImage: 'https://example.com/image.jpg',
    publishedAt: '2026-09-27T00:00:00Z',
    content: 'Test Content',
  );

  setUp(() {
    mockRepository = MockUserArticleRepository();
    usecase = CreateUserArticle(mockRepository);
  });

  test('should call createUserArticle on repository with article and imageFile',
      () async {
    final tImageFile = File('dummy/path/image.jpg');
    when(mockRepository.createUserArticle(
      any,
      imageFile: anyNamed('imageFile'),
    )).thenAnswer((_) async => const DataSuccess(null));

    final result = await usecase(
      params: CreateUserArticleParams(
        article: tArticle,
        imageFile: tImageFile,
      ),
    );

    expect(result, isA<DataSuccess<void>>());
    verify(mockRepository.createUserArticle(
      tArticle,
      imageFile: tImageFile,
    )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call createUserArticle on repository without imageFile',
      () async {
    when(mockRepository.createUserArticle(
      any,
      imageFile: anyNamed('imageFile'),
    )).thenAnswer((_) async => const DataSuccess(null));

    final result = await usecase(
      params: const CreateUserArticleParams(
        article: tArticle,
      ),
    );

    expect(result, isA<DataSuccess<void>>());
    verify(mockRepository.createUserArticle(
      tArticle,
      imageFile: null,
    )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DataFailed when repository fails', () async {
    when(mockRepository.createUserArticle(
      any,
      imageFile: anyNamed('imageFile'),
    )).thenAnswer((_) async => const DataGenericFailed('Failed to create article'));

    final result = await usecase(
      params: const CreateUserArticleParams(
        article: tArticle,
      ),
    );

    expect(result, isA<DataGenericFailed<void>>());
    expect(result.errorMessage, 'Failed to create article');
    verify(mockRepository.createUserArticle(
      tArticle,
      imageFile: null,
    )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DataSuccess and not call repository when params is null',
      () async {
    final result = await usecase(params: null);

    expect(result, isA<DataSuccess<void>>());
    verifyZeroInteractions(mockRepository);
  });

  test('should default a blank author name to Anonymous before saving',
      () async {
    const nameless = ArticleEntity(
      id: '1',
      authorDisplayName: '   ',
      title: 'Test Title',
      urlToImage: 'https://example.com/image.jpg',
      publishedAt: '2026-09-27T00:00:00Z',
      content: 'Test Content',
    );
    when(mockRepository.createUserArticle(
      any,
      imageFile: anyNamed('imageFile'),
    )).thenAnswer((_) async => const DataSuccess(null));

    final result = await usecase(
      params: const CreateUserArticleParams(article: nameless),
    );

    expect(result, isA<DataSuccess<void>>());
    final captured = verify(mockRepository.createUserArticle(
      captureAny,
      imageFile: null,
    )).captured;
    expect((captured.single as ArticleEntity).authorDisplayName, 'Anonymous');
    verifyNoMoreInteractions(mockRepository);
  });
}
