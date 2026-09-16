import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/publish/publish_cubit.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(PublishArticleParams(draft: buildDraft()));
    registerFallbackValue(UpdateArticleParams(article: buildArticle(), draft: buildDraft()));
  });

  late MockPublishArticleUseCase publish;
  late MockUpdateArticleUseCase update;
  late MockPickImageUseCase pick;
  late MockLoadDraftUseCase loadDraft;
  late MockSaveDraftUseCase saveDraft;
  late MockClearDraftUseCase clearDraft;
  final now = DateTime(2026, 9, 16, 9, 41);
  final published = buildUserArticle(id: 'new');

  PublishCubit newCubit() => PublishCubit(publish, update, pick, loadDraft: loadDraft, saveDraft: saveDraft, clearDraft: clearDraft, autosaveDelay: Duration.zero, now: now);

  setUp(() {
    publish = MockPublishArticleUseCase();
    update = MockUpdateArticleUseCase();
    pick = MockPickImageUseCase();
    loadDraft = MockLoadDraftUseCase();
    saveDraft = MockSaveDraftUseCase();
    clearDraft = MockClearDraftUseCase();
    when(() => loadDraft(any())).thenAnswer((_) async => null);
    when(() => saveDraft(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => clearDraft(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => publish(any())).thenAnswer((_) async => DataSuccess(published));
    when(() => update(any())).thenAnswer((_) async => DataSuccess(published));
    when(() => pick(any())).thenAnswer((_) async => DataSuccess(buildImage()));
  });

  test('starts empty, dated now, and cannot submit until title and text exist', () {
    final cubit = newCubit();
    expect(cubit.state.publishedAt, now);
    expect(cubit.state.canSubmit, isFalse);
    expect(cubit.state.canAskEditor, isFalse);
    expect(cubit.state.missingHint, 'Fill in the title and article text to publish.');

    cubit.contentChanged('Body');
    expect(cubit.state.canAskEditor, isTrue);
    expect(cubit.state.canSubmit, isFalse);
    expect(cubit.state.missingHint, 'Add a title to publish.');
    cubit.titleChanged('A title');
    expect(cubit.state.canSubmit, isTrue);
    expect(cubit.state.missingHint, isNull);
  });

  test('editing preloads the article and submits an update with the thumbnail decision', () async {
    final original = buildUserArticle(id: 'doc-1').copyWith(description: 'Old summary');
    final cubit = PublishCubit(publish, update, pick, loadDraft: loadDraft, saveDraft: saveDraft, clearDraft: clearDraft, autosaveDelay: Duration.zero, original: original, now: now);
    expect(cubit.state.isEditing, isTrue);
    expect(cubit.state.title, original.title);
    expect(cubit.state.existingImageUrl, original.imageUrl);

    cubit.removePhoto();
    expect(cubit.state.hasPhoto, isFalse);
    await cubit.submit();

    final params = verify(() => update(captureAny())).captured.single as UpdateArticleParams;
    expect(params.article, original);
    expect(params.removeThumbnail, isTrue);
    expect(params.newThumbnail, isNull);
    expect(cubit.state.status, PublishStatus.success);
    expect(cubit.state.result, published);
    verifyNever(() => publish(any()));
  });

  test('submit validates through the draft and keeps other field errors while typing', () async {
    final cubit = newCubit();
    cubit.titleChanged('x' * (ArticleLimits.titleMaxLength + 1));
    cubit.contentChanged('Body');

    await cubit.submit();
    expect(cubit.state.status, PublishStatus.failure);
    expect(cubit.state.titleError, ArticleValidationError.titleTooLong);
    verifyNever(() => publish(any()));

    cubit.descriptionChanged('fine');
    expect(cubit.state.titleError, ArticleValidationError.titleTooLong);
    cubit.titleChanged('Short');
    expect(cubit.state.titleError, isNull);
  });

  test('a new article is published with the picked photo and category, dated now', () async {
    final cubit = newCubit();
    cubit
      ..titleChanged('A title')
      ..contentChanged('Body')
      ..categoryChanged(NewsCategory.science);
    await cubit.pickPhoto();
    expect(cubit.state.pickedImage, buildImage());

    final before = DateTime.now();
    await cubit.submit();

    final params = verify(() => publish(captureAny())).captured.single as PublishArticleParams;
    expect(params.thumbnail, buildImage());
    expect(params.draft.category, NewsCategory.science);
    expect(params.draft.publishedAt.isBefore(before), isFalse);
    expect(cubit.state.status, PublishStatus.success);
  });

  test('a dismissed picker changes nothing and a bad file reports the failure', () async {
    final cubit = newCubit();
    when(() => pick(any())).thenAnswer((_) async => const DataSuccess(null));
    await cubit.pickPhoto();
    expect(cubit.state.pickedImage, isNull);

    when(() => pick(any()))
        .thenAnswer((_) async => const DataFailed(Failure.validation('Use a JPEG, PNG or WebP image.')));
    await cubit.pickPhoto();
    expect(cubit.state.failure?.type, FailureType.validation);
  });

  test('a rejected publish ends in failure with the reason', () async {
    when(() => publish(any())).thenAnswer((_) async => const DataFailed(Failure.network()));
    final cubit = newCubit()
      ..titleChanged('A title')
      ..contentChanged('Body');

    await cubit.submit();

    expect(cubit.state.status, PublishStatus.failure);
    expect(cubit.state.failure, const Failure.network());
  });

  test('a new article restores the stored draft; an edit never asks for it', () async {
    const kept = SavedDraft(title: 'Kept title', content: 'Kept body', category: NewsCategory.health);
    when(() => loadDraft(any())).thenAnswer((_) async => kept);
    final cubit = newCubit();

    await cubit.restoreDraft();

    expect(cubit.state.title, 'Kept title');
    expect(cubit.state.content, 'Kept body');
    expect(cubit.state.category, NewsCategory.health);
    expect(cubit.state.draftNotice, DraftNotice.restored);
    expect(cubit.state.hasDraftContent, isTrue);
    await cubit.close();

    final editing = PublishCubit(publish, update, pick, loadDraft: loadDraft, saveDraft: saveDraft, clearDraft: clearDraft, autosaveDelay: Duration.zero, original: buildUserArticle());
    await editing.restoreDraft();
    expect(editing.state.title, isNot('Kept title'));
    expect(editing.state.hasDraftContent, isFalse);
    verify(() => loadDraft(any())).called(1);
    await editing.close();
  });

  test('typing is kept as a draft after a pause, not on every keystroke', () {
    fakeAsync((async) {
      final cubit = PublishCubit(
        publish,
        update,
        pick,
        loadDraft: loadDraft,
        saveDraft: saveDraft,
        clearDraft: clearDraft,
        now: now,
        autosaveDelay: const Duration(milliseconds: 300),
      );

      cubit.titleChanged('T');
      cubit.contentChanged('Body');
      async.elapse(const Duration(milliseconds: 100));
      verifyNever(() => saveDraft(any()));

      async.elapse(const Duration(milliseconds: 300));
      verify(() => saveDraft(const SavedDraft(title: 'T', content: 'Body'))).called(1);
      cubit.close();
    });
  });

  test('closing with a pending edit saves it first', () async {
    final cubit = newCubit();
    cubit.titleChanged('Half a thought');

    await cubit.close();

    verify(() => saveDraft(const SavedDraft(title: 'Half a thought'))).called(1);
  });

  test('clear wipes the form and the stored draft', () async {
    final cubit = newCubit();
    cubit.titleChanged('T');
    cubit.contentChanged('B');

    await cubit.clearDraft();

    expect(cubit.state.hasDraftContent, isFalse);
    expect(cubit.state.title, isEmpty);
    expect(cubit.state.draftNotice, DraftNotice.cleared);
    verify(() => clearDraft(any())).called(1);
    await cubit.close();
    verifyNever(() => saveDraft(any()));
  });

  test('publishing forgets the draft', () async {
    final cubit = newCubit();
    cubit.titleChanged('T');
    cubit.contentChanged('B');

    await cubit.submit();

    expect(cubit.state.status, PublishStatus.success);
    verify(() => clearDraft(any())).called(1);
    await cubit.close();
  });
}
