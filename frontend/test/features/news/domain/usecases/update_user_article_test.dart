import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/update_user_article.dart';

import 'update_user_article_test.mocks.dart';

@GenerateMocks([UserArticleRepository])
void main() {
  late MockUserArticleRepository mockRepository;
  late UpdateUserArticle usecase;

  const tArticle = ArticleEntity(
    id: '1',
    authorDisplayName: 'John Doe',
    title: 'Test Title',
    urlToImage: 'https://example.com/image.jpg',
    publishedAt: '2026-09-27T00:00:00Z',
    content: 'Test Content',
    authorId: 'user-123',
  );

  setUp(() {
    mockRepository = MockUserArticleRepository();
    usecase = UpdateUserArticle(mockRepository);
  });

  test('should call updateUserArticle on repository with article and imageFile',
      () async {
    final tImageFile = File('dummy/path/image.jpg');
    when(mockRepository.updateUserArticle(
      any,
      imageFile: anyNamed('imageFile'),
    )).thenAnswer((_) async => const DataSuccess(null));

    final result = await usecase(
      params: UpdateUserArticleParams(
        article: tArticle,
        imageFile: tImageFile,
      ),
    );

    expect(result, isA<DataSuccess<void>>());
    verify(mockRepository.updateUserArticle(
      tArticle,
      imageFile: tImageFile,
    )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call updateUserArticle on repository without imageFile',
      () async {
    when(mockRepository.updateUserArticle(
      any,
      imageFile: anyNamed('imageFile'),
    )).thenAnswer((_) async => const DataSuccess(null));

    final result = await usecase(
      params: const UpdateUserArticleParams(
        article: tArticle,
      ),
    );

    expect(result, isA<DataSuccess<void>>());
    verify(mockRepository.updateUserArticle(
      tArticle,
      imageFile: null,
    )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DataFailed when repository fails', () async {
    when(mockRepository.updateUserArticle(
      any,
      imageFile: anyNamed('imageFile'),
    )).thenAnswer(
        (_) async => const DataGenericFailed('Failed to update article'));

    final result = await usecase(
      params: const UpdateUserArticleParams(
        article: tArticle,
      ),
    );

    expect(result, isA<DataGenericFailed<void>>());
    verify(mockRepository.updateUserArticle(
      tArticle,
      imageFile: null,
    )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DataGenericFailed when params are null', () async {
    final result = await usecase();

    expect(result, isA<DataGenericFailed<void>>());
    verifyZeroInteractions(mockRepository);
  });
}
