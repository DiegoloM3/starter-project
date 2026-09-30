import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/invalid_article_draft_exception.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/discard_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/pick_thumbnail_from_gallery.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/resume_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/save_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/publish_article/publish_article_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/publish_article/publish_article_state.dart';

import '../../../../../helpers/cubit_states.dart';

class MockPublishArticleUseCase extends Mock implements PublishArticleUseCase {}

class MockPickThumbnailFromGalleryUseCase extends Mock implements PickThumbnailFromGalleryUseCase {}

class MockResumeDraftUseCase extends Mock implements ResumeDraftUseCase {}

class MockSaveDraftUseCase extends Mock implements SaveDraftUseCase {}

class MockDiscardDraftUseCase extends Mock implements DiscardDraftUseCase {}

const thumbnail = ArticleThumbnailEntity(localPath: '/gallery/photo.jpg', sizeInBytes: 1024);

const validDraft = ArticleDraftEntity(
  title: 'Breaking News!',
  content: 'This is **breaking** news.',
  author: 'Daily News Staff',
  thumbnail: thumbnail,
);

void main() {
  late MockPublishArticleUseCase publishArticle;
  late MockPickThumbnailFromGalleryUseCase pickThumbnail;
  late MockResumeDraftUseCase resumeDraft;
  late MockSaveDraftUseCase saveDraft;
  late MockDiscardDraftUseCase discardDraft;
  late PublishArticleCubit cubit;

  setUpAll(() => registerFallbackValue(const ArticleDraftEntity()));

  setUp(() {
    publishArticle = MockPublishArticleUseCase();
    pickThumbnail = MockPickThumbnailFromGalleryUseCase();
    resumeDraft = MockResumeDraftUseCase();
    saveDraft = MockSaveDraftUseCase();
    discardDraft = MockDiscardDraftUseCase();
    cubit = PublishArticleCubit(publishArticle, pickThumbnail, resumeDraft, saveDraft, discardDraft);
    when(() => saveDraft(params: any(named: 'params'))).thenAnswer((_) async => const DataSuccess(null));
    when(() => discardDraft()).thenAnswer((_) async => const DataSuccess(null));
  });

  tearDown(() => cubit.close());

  void givenPublishResult(DataState<void> result) {
    when(() => publishArticle(params: any(named: 'params'))).thenAnswer((_) async => result);
  }

  void givenPickedThumbnail(DataState<ArticleThumbnailEntity?> result) {
    when(() => pickThumbnail()).thenAnswer((_) async => result);
  }

  void fillInValidDraft() {
    cubit
      ..changeTitle(validDraft.title)
      ..changeContent(validDraft.content)
      ..changeAuthor(validDraft.author);
    givenPickedThumbnail(const DataSuccess(thumbnail));
  }

  test('starts editing an empty draft', () {
    expect(cubit.state, const PublishArticleEditing(ArticleDraftEntity()));
  });

  group('editing', () {
    test('updates the draft on every change', () async {
      final states = await statesEmittedBy(cubit, () async {
        cubit
          ..changeTitle('Title')
          ..changeContent('Body')
          ..changeAuthor('Me');
      });

      expect(states.last, const PublishArticleEditing(ArticleDraftEntity(title: 'Title', content: 'Body', author: 'Me')));
    });

    test('does not show errors while the journalist is still writing', () async {
      final states = await statesEmittedBy(cubit, () async => cubit.changeTitle(''));

      expect(states.single, isA<PublishArticleEditing>());
    });
  });

  group('publishing an invalid draft', () {
    test('shows every field error and does not call the use case', () async {
      final states = await statesEmittedBy(cubit, cubit.publish);

      expect(states.single, const PublishArticleInvalid(ArticleDraftEntity(), {
        ArticleDraftError.titleEmpty,
        ArticleDraftError.contentEmpty,
        ArticleDraftError.authorEmpty,
        ArticleDraftError.thumbnailMissing,
      }));
      verifyNever(() => publishArticle(params: any(named: 'params')));
    });

    test('updates the errors live while they are being fixed', () async {
      await cubit.publish();

      cubit.changeTitle('Now with a title');

      expect((cubit.state as PublishArticleInvalid).errors, isNot(contains(ArticleDraftError.titleEmpty)));
    });

    test('goes back to editing once every error is fixed', () async {
      await cubit.publish();
      fillInValidDraft();

      await cubit.pickThumbnail();

      expect(cubit.state, const PublishArticleEditing(validDraft));
    });
  });

  group('publishing a valid draft', () {
    setUp(() async {
      fillInValidDraft();
      await cubit.pickThumbnail();
    });

    test('goes through publishing to success', () async {
      givenPublishResult(const DataSuccess(null));

      final states = await statesEmittedBy(cubit, cubit.publish);

      expect(states, const [PublishArticlePublishing(validDraft), PublishArticleSuccess(validDraft)]);
      verify(() => publishArticle(params: validDraft)).called(1);
    });

    test('reports a failure when publishing fails', () async {
      givenPublishResult(DataFailed(Exception('network down')));

      final states = await statesEmittedBy(cubit, cubit.publish);

      expect(states, const [
        PublishArticlePublishing(validDraft),
        PublishArticleFailure(validDraft, PublishArticleFailureReason.publishFailed),
      ]);
    });

    test('shows the errors the use case found', () async {
      givenPublishResult(const DataFailed(InvalidArticleDraftException({ArticleDraftError.titleTooLong})));

      final states = await statesEmittedBy(cubit, cubit.publish);

      expect(states.last, const PublishArticleInvalid(validDraft, {ArticleDraftError.titleTooLong}));
    });

    test('ignores a second tap while it is publishing', () async {
      final pendingPublish = Completer<DataState<void>>();
      when(() => publishArticle(params: any(named: 'params'))).thenAnswer((_) => pendingPublish.future);

      final firstTap = cubit.publish();
      await cubit.publish();
      pendingPublish.complete(const DataSuccess(null));
      await firstTap;

      verify(() => publishArticle(params: any(named: 'params'))).called(1);
    });

    test('goes back to editing when the journalist edits after a failure', () async {
      givenPublishResult(DataFailed(Exception('network down')));
      await cubit.publish();

      cubit.changeTitle('Retry');

      expect(cubit.state, isA<PublishArticleEditing>());
    });
  });

  group('thumbnail', () {
    test('adds the picked image to the draft', () async {
      givenPickedThumbnail(const DataSuccess(thumbnail));

      await cubit.pickThumbnail();

      expect(cubit.state.draft.thumbnail, thumbnail);
    });

    test('keeps the current image when the journalist cancels the gallery', () async {
      givenPickedThumbnail(const DataSuccess(null));

      final states = await statesEmittedBy(cubit, cubit.pickThumbnail);

      expect(states, isEmpty);
    });

    test('reports when the gallery cannot be opened', () async {
      givenPickedThumbnail(DataFailed(PlatformException(code: 'photo_access_denied')));

      await cubit.pickThumbnail();

      expect(cubit.state, const PublishArticleFailure(ArticleDraftEntity(), PublishArticleFailureReason.galleryUnavailable));
    });
  });

  group('resuming a draft', () {
    void givenDraftToResume(ArticleDraftEntity draft) {
      when(() => resumeDraft()).thenAnswer((_) async => DataSuccess(draft));
    }

    test('shows the draft left unfinished, telling it was restored', () async {
      givenDraftToResume(validDraft);

      await cubit.resumeDraft();

      expect(cubit.state, const PublishArticleDraftLoaded(validDraft, isRestored: true));
    });

    test('starts a new draft signed like the previous article', () async {
      givenDraftToResume(const ArticleDraftEntity(author: 'Daily News Staff'));

      await cubit.resumeDraft();

      expect(cubit.state, const PublishArticleDraftLoaded(ArticleDraftEntity(author: 'Daily News Staff'), isRestored: false));
    });

    test('never overwrites what the journalist already typed', () async {
      givenDraftToResume(validDraft);
      cubit.changeAuthor('Someone else');

      await cubit.resumeDraft();

      expect(cubit.state.draft, const ArticleDraftEntity(author: 'Someone else'));
    });

    test('starting over discards the saved draft and keeps the signature', () async {
      givenDraftToResume(validDraft);
      await cubit.resumeDraft();

      await cubit.startOver();

      verify(() => discardDraft()).called(1);
      expect(cubit.state, PublishArticleDraftLoaded(ArticleDraftEntity(author: validDraft.author), isRestored: false));
    });
  });

  group('saving the draft', () {
    test('saves it once the journalist pauses typing', () {
      // Its own cubit: work started under fake time only completes under fake time.
      fakeAsync((time) {
        final cubit = PublishArticleCubit(publishArticle, pickThumbnail, resumeDraft, saveDraft, discardDraft)
          ..changeTitle('T')
          ..changeTitle('Ti');
        time.elapse(PublishArticleCubit.draftSavingDelay ~/ 2);
        verifyNever(() => saveDraft(params: any(named: 'params')));

        time.elapse(PublishArticleCubit.draftSavingDelay);

        verify(() => saveDraft(params: const ArticleDraftEntity(title: 'Ti'))).called(1);
        cubit.close();
        time.flushMicrotasks();
      });
    });

    test('saves the latest changes right away when the form is closed', () async {
      cubit.changeContent('Unfinished');

      await cubit.close();

      verify(() => saveDraft(params: const ArticleDraftEntity(content: 'Unfinished'))).called(1);
    });

    test('saves it before publishing, so it survives a failed publication', () async {
      fillInValidDraft();
      await cubit.pickThumbnail();
      givenPublishResult(DataFailed(Exception('network down')));

      await cubit.publish();

      verifyInOrder([
        () => saveDraft(params: validDraft),
        () => publishArticle(params: validDraft),
      ]);
    });

    test('saves one draft at a time, in the order they were written', () async {
      final firstSave = Completer<DataState<void>>();
      final saved = <String>[];
      when(() => saveDraft(params: any(named: 'params'))).thenAnswer((invocation) async {
        final draft = invocation.namedArguments[#params] as ArticleDraftEntity;
        if (saved.isEmpty && !firstSave.isCompleted) await firstSave.future;
        saved.add(draft.title);
        return const DataSuccess(null);
      });
      fillInValidDraft();
      await cubit.pickThumbnail();
      givenPublishResult(DataFailed(Exception('network down')));
      final publishing = cubit.publish(); // saves "Breaking News!" and waits
      await Future<void>.delayed(Duration.zero);

      firstSave.complete(const DataSuccess(null));
      await publishing;
      cubit.changeTitle('Second');
      await cubit.close();

      expect(saved, ['Breaking News!', 'Second']);
    });

    test('discarding drops the changes not saved yet', () async {
      cubit.changeTitle('Unwanted');

      await cubit.discardDraft();
      await cubit.close();

      verify(() => discardDraft()).called(1);
      verifyNever(() => saveDraft(params: any(named: 'params')));
    });
  });

  group('hasStartedWriting', () {
    test('is false for an untouched draft', () {
      expect(cubit.state.hasStartedWriting, isFalse);
    });

    test('is false when only the prefilled signature is there', () {
      cubit.changeAuthor('Daily News Staff');

      expect(cubit.state.hasStartedWriting, isFalse);
    });

    test('is true once the journalist has written something', () {
      cubit.changeContent('A');

      expect(cubit.state.hasStartedWriting, isTrue);
    });
  });
}
