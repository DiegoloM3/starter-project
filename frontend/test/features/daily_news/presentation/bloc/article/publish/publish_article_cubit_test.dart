import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/pick_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/publish/publish_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/publish/publish_article_state.dart';

class MockPublishArticleUseCase extends Mock implements PublishArticleUseCase {}

class MockPickArticleThumbnailUseCase extends Mock implements PickArticleThumbnailUseCase {}

void main() {
  late MockPublishArticleUseCase publishArticle;
  late MockPickArticleThumbnailUseCase pickArticleThumbnail;
  late PublishArticleCubit cubit;

  const thumbnailPath = '/images/thumbnail.jpg';

  setUpAll(() {
    registerFallbackValue(const PublishArticleParams(ArticleDraftEntity(title: '', content: '')));
  });

  setUp(() {
    publishArticle = MockPublishArticleUseCase();
    pickArticleThumbnail = MockPickArticleThumbnailUseCase();
    cubit = PublishArticleCubit(publishArticle, pickArticleThumbnail);
  });

  tearDown(() => cubit.close());

  void stubPublicationResult(DataState<void> result) {
    when(() => publishArticle(params: any(named: 'params'))).thenAnswer((_) async => result);
  }

  void stubPickedThumbnail(DataState<String?> result) {
    when(() => pickArticleThumbnail()).thenAnswer((_) async => result);
  }

  group('PublishArticleCubit', () {
    test('starts with an empty draft being edited', () {
      expect(cubit.state, const PublishArticleState());
    });

    test('updates the title and the content', () {
      cubit.changeTitle('Breaking News!');
      cubit.changeContent('This is breaking news!');

      expect(cubit.state.title, 'Breaking News!');
      expect(cubit.state.content, 'This is breaking news!');
    });

    test('stores the thumbnail picked from the gallery', () async {
      stubPickedThumbnail(const DataSuccess(thumbnailPath));

      await cubit.pickThumbnail();

      expect(cubit.state.thumbnailPath, thumbnailPath);
    });

    test('replaces the thumbnail when another one is picked', () async {
      stubPickedThumbnail(const DataSuccess(thumbnailPath));
      await cubit.pickThumbnail();
      stubPickedThumbnail(const DataSuccess('/images/another.jpg'));

      await cubit.pickThumbnail();

      expect(cubit.state.thumbnailPath, '/images/another.jpg');
    });

    test('keeps the current thumbnail when the gallery is closed without picking', () async {
      stubPickedThumbnail(const DataSuccess(thumbnailPath));
      await cubit.pickThumbnail();
      stubPickedThumbnail(const DataSuccess(null));

      await cubit.pickThumbnail();

      expect(cubit.state.thumbnailPath, thumbnailPath);
    });

    test('reports a failure when the gallery cannot be opened', () async {
      stubPickedThumbnail(DataFailed(Exception('Gallery unavailable')));

      await cubit.pickThumbnail();

      expect(cubit.state.status, PublishArticleStatus.failure);
    });

    test('emits publishing and then published for a valid draft', () async {
      stubPublicationResult(const DataSuccess(null));
      cubit.changeTitle('Breaking News!');

      final states = expectLater(
        cubit.stream.map((state) => state.status),
        emitsInOrder([PublishArticleStatus.publishing, PublishArticleStatus.published]),
      );
      await cubit.publish();
      await states;
    });

    test('publishes the draft built from the current state', () async {
      stubPublicationResult(const DataSuccess(null));
      stubPickedThumbnail(const DataSuccess(thumbnailPath));
      cubit.changeTitle('Breaking News!');
      cubit.changeContent('This is breaking news!');
      await cubit.pickThumbnail();

      await cubit.publish();

      final params = verify(() => publishArticle(params: captureAny(named: 'params'))).captured.single
          as PublishArticleParams;
      expect(params.draft, const ArticleDraftEntity(
        title: 'Breaking News!',
        content: 'This is breaking news!',
        thumbnailPath: thumbnailPath,
      ));
    });

    test('exposes the validation errors of an invalid draft', () async {
      const errors = [ArticleDraftError.emptyTitle, ArticleDraftError.missingThumbnail];
      stubPublicationResult(const DataFailed(ArticleDraftValidationException(errors)));

      await cubit.publish();

      expect(cubit.state.status, PublishArticleStatus.invalid);
      expect(cubit.state.validationErrors, errors);
    });

    test('clears the validation errors when the draft is edited', () async {
      stubPublicationResult(const DataFailed(ArticleDraftValidationException([ArticleDraftError.emptyTitle])));
      await cubit.publish();

      cubit.changeTitle('Breaking News!');

      expect(cubit.state.status, PublishArticleStatus.editing);
      expect(cubit.state.validationErrors, isEmpty);
    });

    test('reports a failure when the publication fails for another reason', () async {
      stubPublicationResult(DataFailed(Exception('No connection')));

      await cubit.publish();

      expect(cubit.state.status, PublishArticleStatus.failure);
    });

    test('ignores a second publication while one is in progress', () async {
      stubPublicationResult(const DataSuccess(null));

      await Future.wait([cubit.publish(), cubit.publish()]);

      verify(() => publishArticle(params: any(named: 'params'))).called(1);
    });
  });
}
