import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/data/data_sources/remote/article_image_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/articles/data/data_sources/remote/article_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/articles/data/models/article_model.dart';
import 'package:news_app_clean_architecture/features/articles/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_content.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_draft.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_image.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/update_article_params.dart';

class MockArticleRemoteDataSource extends Mock implements ArticleRemoteDataSource {}

class MockArticleImageRemoteDataSource extends Mock implements ArticleImageRemoteDataSource {}

final article = ArticleModel(
  id: 'article-1',
  title: 'Title',
  description: 'Description',
  content: ArticleContent.fromPlainText('Content'),
  thumbnailURL: 'https://example.com/image.jpg',
  topics: const [ArticleTopic.sports],
  publishedAt: DateTime(2026, 10, 16),
  authorId: 'journalist-1',
  authorName: 'Jane Doe',
);

void main() {
  late MockArticleRemoteDataSource articleDataSource;
  late MockArticleImageRemoteDataSource imageDataSource;
  late ArticleRepositoryImpl repository;
  final image = ArticleImage(Uint8List(10));
  final draft = ArticleDraft(
    title: 'Title',
    description: 'Description',
    content: ArticleContent.fromPlainText('Content'),
    topics: const {ArticleTopic.sports},
  );

  setUpAll(() {
    registerFallbackValue(draft);
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    articleDataSource = MockArticleRemoteDataSource();
    imageDataSource = MockArticleImageRemoteDataSource();
    repository = ArticleRepositoryImpl(articleDataSource, imageDataSource);
  });

  test('gets the articles as entities', () async {
    when(() => articleDataSource.getArticles()).thenAnswer((_) async => [article]);

    final result = await repository.getArticles();

    expect(result.data, [article.toEntity()]);
  });

  test('gets the articles of the authors as entities', () async {
    when(() => articleDataSource.getArticlesByAuthors(['journalist-1'])).thenAnswer((_) async => [article]);

    final result = await repository.getArticlesByAuthors(['journalist-1']);

    expect(result.data, [article.toEntity()]);
  });

  test('fails with the exception of the data source', () async {
    final error = Exception('offline');
    when(() => articleDataSource.getArticles()).thenThrow(error);

    final result = await repository.getArticles();

    expect(result.error, error);
  });

  test('uploads the thumbnail before publishing the article with its URL', () async {
    when(() => imageDataSource.uploadImage(image.bytes)).thenAnswer((_) async => 'https://thumbnail');
    when(() => articleDataSource.createArticle(draft, 'https://thumbnail')).thenAnswer((_) async => article);

    final result = await repository.publishArticle(PublishArticleParams(draft: draft, thumbnail: image));

    expect(result.data, article.toEntity());
  });

  test('keeps the current thumbnail when updating without a new one', () async {
    when(() => articleDataSource.updateArticle('article-1', draft)).thenAnswer((_) async => article);

    final result = await repository.updateArticle(UpdateArticleParams(articleId: 'article-1', draft: draft));

    expect(result.data, article.toEntity());
    verifyNever(() => imageDataSource.uploadImage(any()));
  });

  test('uploads the new thumbnail when updating with one', () async {
    when(() => imageDataSource.uploadImage(image.bytes)).thenAnswer((_) async => 'https://new');
    when(
      () => articleDataSource.updateArticle('article-1', draft, newThumbnailURL: 'https://new'),
    ).thenAnswer((_) async => article);

    final params = UpdateArticleParams(articleId: 'article-1', draft: draft, newThumbnail: image);
    final result = await repository.updateArticle(params);

    expect(result, isA<DataSuccess>());
  });

  test('deletes the article', () async {
    when(() => articleDataSource.deleteArticle('article-1')).thenAnswer((_) async {});

    final result = await repository.deleteArticle('article-1');

    expect(result, isA<DataSuccess>());
  });

  test('uploads content images', () async {
    when(() => imageDataSource.uploadImage(image.bytes)).thenAnswer((_) async => 'https://img');

    final result = await repository.uploadArticleImage(image);

    expect(result.data, 'https://img');
  });
}
