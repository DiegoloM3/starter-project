import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/data/data_sources/article_remote_data_source.dart';
import 'package:tortutip/features/articles/data/models/article_model.dart';
import 'package:tortutip/features/articles/data/repository/article_repository_impl.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/params/publish_article_params.dart';
import 'package:tortutip/features/articles/domain/params/update_article_params.dart';
import 'package:tortutip/features/articles/domain/params/upload_article_image_params.dart';

class MockArticleRemoteDataSource extends Mock
    implements ArticleRemoteDataSource {}

void main() {
  late ArticleRepositoryImpl repository;
  late MockArticleRemoteDataSource mockDataSource;

  const params = PublishArticleParams(
    authorId: 'user_1',
    categoryId: 'cat_1',
    title: 'Title',
    body: 'Body',
    coverVerticalUrl: '',
    coverHorizontalUrl: '',
  );

  setUp(() {
    mockDataSource = MockArticleRemoteDataSource();
    repository = ArticleRepositoryImpl(mockDataSource);
    registerFallbackValue(params);
    registerFallbackValue(
      UploadArticleImageParams(
        userId: 'user_1',
        imageFile: File('test.jpg'),
        isVertical: true,
      ),
    );
  });

  group('ArticleRepositoryImpl.getFeedArticles', () {
    test('should_return_DataSuccess_with_entities_when_datasource_succeeds',
        () async {
      when(() => mockDataSource.getFeedArticles(any()))
          .thenAnswer((_) async => <ArticleModel>[]);

      final result = await repository.getFeedArticles(['cat_1']);

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.getFeedArticles(any()))
          .thenThrow(Exception('error'));

      final result = await repository.getFeedArticles(['cat_1']);

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
    });
  });

  group('ArticleRepositoryImpl.getArticleDetail', () {
    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.getArticleDetail(any()))
          .thenThrow(Exception('not found'));

      final result = await repository.getArticleDetail('art_1');

      expect(result, isA<DataFailed<ArticleEntity>>());
    });
  });

  group('ArticleRepositoryImpl.saveArticle', () {
    test('should_return_DataSuccess_when_datasource_succeeds', () async {
      when(() => mockDataSource.saveArticle(any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.saveArticle('user_1', 'art_1');

      expect(result, isA<DataSuccess<bool>>());
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.saveArticle(any(), any()))
          .thenThrow(Exception('error'));

      final result = await repository.saveArticle('user_1', 'art_1');

      expect(result, isA<DataFailed<bool>>());
    });
  });

  group('ArticleRepositoryImpl.getUserArticles', () {
    test('should_return_DataSuccess_with_entities_when_datasource_succeeds',
        () async {
      when(() => mockDataSource.getUserArticles(any()))
          .thenAnswer((_) async => <ArticleModel>[]);

      final result = await repository.getUserArticles('user_1');

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.getUserArticles(any()))
          .thenThrow(Exception('error'));

      final result = await repository.getUserArticles('user_1');

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
    });
  });

  group('ArticleRepositoryImpl.getSavedArticleIds', () {
    test('should_return_DataSuccess_with_ids_when_datasource_succeeds',
        () async {
      when(() => mockDataSource.getSavedArticleIds(any()))
          .thenAnswer((_) async => ['article_1', 'article_2']);

      final result = await repository.getSavedArticleIds('user_1');

      expect(result, isA<DataSuccess<List<String>>>());
      expect(result.data, equals(['article_1', 'article_2']));
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.getSavedArticleIds(any()))
          .thenThrow(Exception('error'));

      final result = await repository.getSavedArticleIds('user_1');

      expect(result, isA<DataFailed<List<String>>>());
    });
  });

  group('ArticleRepositoryImpl.getFeedArticlesPaged', () {
    test('should_return_DataSuccess_with_entities_when_datasource_succeeds',
        () async {
      when(() => mockDataSource.getFeedArticlesPaged(any(), any(), any()))
          .thenAnswer((_) async => <ArticleModel>[]);

      final result = await repository.getFeedArticlesPaged(['cat_1'], 0, 10);

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.getFeedArticlesPaged(any(), any(), any()))
          .thenThrow(Exception('error'));

      final result = await repository.getFeedArticlesPaged(['cat_1'], 0, 10);

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
    });
  });

  group('ArticleRepositoryImpl.unsaveArticle', () {
    test('should_return_DataSuccess_when_datasource_succeeds', () async {
      when(() => mockDataSource.unsaveArticle(any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.unsaveArticle('user_1', 'article_1');

      expect(result, isA<DataSuccess<bool>>());
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.unsaveArticle(any(), any()))
          .thenThrow(Exception('error'));

      final result = await repository.unsaveArticle('user_1', 'article_1');

      expect(result, isA<DataFailed<bool>>());
    });
  });

  group('ArticleRepositoryImpl.getRelatedArticles', () {
    test(
        'should_return_DataSuccess_with_entities_when_getRelatedArticles_datasource_succeeds',
        () async {
      when(() => mockDataSource.getRelatedArticles(any(), any()))
          .thenAnswer((_) async => <ArticleModel>[]);

      final result = await repository.getRelatedArticles('cat_1', 'art_1');

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
    });

    test('should_return_DataFailed_when_getRelatedArticles_datasource_throws',
        () async {
      when(() => mockDataSource.getRelatedArticles(any(), any()))
          .thenThrow(Exception('error'));

      final result = await repository.getRelatedArticles('cat_1', 'art_1');

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
    });
  });

  group('ArticleRepositoryImpl.uploadArticleImage', () {
    final uploadParams = UploadArticleImageParams(
      userId: 'user_1',
      imageFile: File('test.jpg'),
      isVertical: true,
    );

    test('should_return_DataSuccess_with_url_when_datasource_succeeds',
        () async {
      when(() => mockDataSource.uploadArticleImage(any()))
          .thenAnswer((_) async => 'https://storage/img.jpg');

      final result = await repository.uploadArticleImage(uploadParams);

      expect(result, isA<DataSuccess<String>>());
      expect(result.data, equals('https://storage/img.jpg'));
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.uploadArticleImage(any()))
          .thenThrow(Exception('Storage error'));

      final result = await repository.uploadArticleImage(uploadParams);

      expect(result, isA<DataFailed<String>>());
    });
  });

  group('ArticleRepositoryImpl.updateArticle', () {
    const updateParams = UpdateArticleParams(
      articleId: 'art_1',
      categoryId: 'cat_1',
      title: 'Updated',
      body: 'Body',
      coverVerticalUrl: '',
      coverHorizontalUrl: '',
      readTimeMinutes: 2,
    );

    final model = ArticleModel(
      id: 'art_1',
      authorId: 'user_1',
      categoryId: 'cat_1',
      title: 'Updated',
      body: 'Body',
      coverVerticalUrl: '',
      coverHorizontalUrl: '',
      status: 'published',
      readTimeMinutes: 2,
      saveCount: 0,
      createdAt: DateTime(2024),
    );

    test('should_return_DataSuccess_when_datasource_succeeds', () async {
      when(() => mockDataSource.updateArticle(updateParams))
          .thenAnswer((_) async => model);

      final result = await repository.updateArticle(updateParams);

      expect(result, isA<DataSuccess<ArticleEntity>>());
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.updateArticle(updateParams))
          .thenThrow(Exception('Firestore error'));

      final result = await repository.updateArticle(updateParams);

      expect(result, isA<DataFailed<ArticleEntity>>());
    });
  });
}
