import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/journalist_article_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/publish_article.dart';

class MockJournalistArticleRepository extends Mock implements JournalistArticleRepository {}

void main() {
  late MockJournalistArticleRepository repository;
  late PublishArticleUseCase publishArticle;

  final validDraft = ArticleDraftEntity(
    title: 'Local startup brings clean water to 10,000 homes',
    description: 'A team of engineers has designed a low-cost filter.',
    content: 'When the first prototype was installed last spring...',
    thumbnail: ArticleThumbnailEntity(bytes: Uint8List(1024), fileExtension: 'jpg'),
  );

  final publishedArticle = JournalistArticleEntity(
    id: 'article1',
    title: validDraft.title,
    description: validDraft.description,
    content: validDraft.content,
    author: 'Jane Doe',
    authorId: 'janeDoeUid',
    thumbnailURL: 'https://example.com/thumbnail.jpg',
    publishedAt: DateTime.utc(2026, 9, 30),
  );

  setUpAll(() => registerFallbackValue(const ArticleDraftEntity()));

  setUp(() {
    repository = MockJournalistArticleRepository();
    publishArticle = PublishArticleUseCase(repository);
  });

  test('publishes a valid draft through the repository', () async {
    when(() => repository.publishArticle(validDraft))
        .thenAnswer((_) async => DataSuccess(publishedArticle));

    final dataState = await publishArticle(params: validDraft);

    expect(dataState, isA<DataSuccess>());
    expect(dataState.data, publishedArticle);
    verify(() => repository.publishArticle(validDraft)).called(1);
  });

  test('returns the failure of the repository', () async {
    final error = Exception('No connection');
    when(() => repository.publishArticle(validDraft)).thenAnswer((_) async => DataFailed(error));

    final dataState = await publishArticle(params: validDraft);

    expect(dataState, isA<DataFailed>());
    expect(dataState.error, error);
  });

  test('refuses to publish a draft that breaks its rules without reaching the repository', () async {
    const invalidDraft = ArticleDraftEntity(title: 'Only a title');

    final dataState = await publishArticle(params: invalidDraft);

    expect(dataState, isA<DataFailed>());
    expect(dataState.error, isA<InvalidArticleDraftException>());
    expect((dataState.error! as InvalidArticleDraftException).draft, invalidDraft);
    verifyNever(() => repository.publishArticle(any()));
  });
}
