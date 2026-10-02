import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/pick_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/publish_article/publish_article_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/publish_article/publish_article_state.dart';

class MockPublishArticleUseCase extends Mock implements PublishArticleUseCase {}

class MockPickArticleThumbnailUseCase extends Mock implements PickArticleThumbnailUseCase {}

void main() {
  late MockPublishArticleUseCase publishArticle;
  late MockPickArticleThumbnailUseCase pickArticleThumbnail;
  late PublishArticleCubit cubit;

  final thumbnail = ArticleThumbnailEntity(bytes: Uint8List(1024), fileExtension: 'png');
  final publishedArticle = JournalistArticleEntity(
    id: 'article1',
    title: 'A title',
    description: 'A description',
    content: 'Some content',
    author: 'Jane Doe',
    authorId: 'janeDoeUid',
    thumbnailURL: 'https://example.com/thumbnail.png',
    publishedAt: DateTime.utc(2026, 9, 30),
  );

  setUpAll(() => registerFallbackValue(const ArticleDraftEntity()));

  setUp(() {
    publishArticle = MockPublishArticleUseCase();
    pickArticleThumbnail = MockPickArticleThumbnailUseCase();
    cubit = PublishArticleCubit(publishArticle, pickArticleThumbnail);
  });

  tearDown(() => cubit.close());

  void stubPublishResult(DataState<JournalistArticleEntity> result) {
    when(() => publishArticle(params: any(named: 'params'))).thenAnswer((_) async => result);
  }

  test('starts editing an empty draft without showing errors', () {
    expect(cubit.state, const PublishArticleEditing(ArticleDraftEntity()));
  });

  group('editing', () {
    test('updates every text field of the draft', () {
      cubit
        ..updateTitle('A title')
        ..updateDescription('A description')
        ..updateContent('Some content');

      expect(
        cubit.state.draft,
        const ArticleDraftEntity(
          title: 'A title',
          description: 'A description',
          content: 'Some content',
        ),
      );
    });

    test('adds the thumbnail chosen in the gallery', () async {
      when(() => pickArticleThumbnail()).thenAnswer((_) async => DataSuccess(thumbnail));

      await cubit.pickThumbnail();

      expect(cubit.state, PublishArticleEditing(ArticleDraftEntity(thumbnail: thumbnail)));
    });

    test('keeps the draft as it was when the gallery is closed without choosing', () async {
      when(() => pickArticleThumbnail()).thenAnswer((_) async => const DataSuccess(null));

      await cubit.pickThumbnail();

      expect(cubit.state, const PublishArticleEditing(ArticleDraftEntity()));
    });

    test('shows a failure when the gallery cannot be opened', () async {
      final error = Exception('Permission denied');
      when(() => pickArticleThumbnail()).thenAnswer((_) async => DataFailed(error));

      await cubit.pickThumbnail();

      expect(cubit.state, PublishArticleFailure(const ArticleDraftEntity(), error));
    });
  });

  group('publishing', () {
    test('shows that it is publishing and then the published article', () async {
      stubPublishResult(DataSuccess(publishedArticle));
      cubit.updateTitle('A title');
      final draft = cubit.state.draft;

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          PublishArticleInProgress(draft),
          PublishArticleSuccess(draft, publishedArticle),
        ]),
      );
      await cubit.publish();
      await states;
      verify(() => publishArticle(params: draft)).called(1);
    });

    test('shows the validation errors when the draft breaks its rules', () async {
      const draft = ArticleDraftEntity();
      stubPublishResult(DataFailed(InvalidArticleDraftException(draft)));

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          const PublishArticleInProgress(draft),
          const PublishArticleEditing(draft, showsValidationErrors: true),
        ]),
      );
      await cubit.publish();
      await states;
    });

    test('keeps showing the validation errors while the journalist fixes the draft', () async {
      stubPublishResult(DataFailed(InvalidArticleDraftException(const ArticleDraftEntity())));
      await cubit.publish();

      cubit.updateTitle('A title');

      expect(
        cubit.state,
        const PublishArticleEditing(ArticleDraftEntity(title: 'A title'), showsValidationErrors: true),
      );
    });

    test('shows a failure when the article cannot be published', () async {
      final error = Exception('No connection');
      stubPublishResult(DataFailed(error));

      await cubit.publish();

      expect(cubit.state, PublishArticleFailure(const ArticleDraftEntity(), error));
    });
  });
}
