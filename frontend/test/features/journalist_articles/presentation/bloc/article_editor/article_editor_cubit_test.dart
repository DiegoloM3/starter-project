import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/create_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_article_by_id.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/pick_article_cover.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/update_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/upload_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_editor/article_editor_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_editor/article_editor_state.dart';

import '../../../../../helpers/article_fixtures.dart';
import '../../../../../helpers/fake_article_thumbnail_repository.dart';
import '../../../../../helpers/fake_cover_image_picker_repository.dart';
import '../../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository articleRepository;
  late FakeArticleThumbnailRepository thumbnailRepository;
  late FakeCoverImagePickerRepository pickerRepository;
  late ArticleEditorCubit cubit;

  setUp(() {
    articleRepository = FakeJournalistArticleRepository();
    thumbnailRepository = FakeArticleThumbnailRepository();
    pickerRepository = FakeCoverImagePickerRepository();
    cubit = ArticleEditorCubit(
      GetArticleByIdUseCase(articleRepository),
      CreateArticleUseCase(articleRepository),
      UpdateArticleUseCase(articleRepository),
      PublishArticleUseCase(articleRepository),
      UploadArticleThumbnailUseCase(thumbnailRepository),
      PickArticleCoverUseCase(pickerRepository),
      journalistId: 'journalist-1',
      journalistName: 'Alex Rivera',
    );
  });

  tearDown(() => cubit.close());

  /// Fills the editor with an article that satisfies every publishing rule.
  void writeCompleteArticle() {
    cubit.startNewArticle();
    cubit.titleChanged('The night bus driver');
    cubit.descriptionChanged('A ride along the last line of the night.');
    cubit.contentChanged('The depot doors open at 23:40.');
  }

  test('starts a new article owned by the signed in journalist', () {
    cubit.startNewArticle();

    expect(cubit.state.article.author, 'Alex Rivera');
    expect(cubit.state.article.userId, 'journalist-1');
    expect(cubit.state.article.isStored, isFalse);
  });

  test('loads a stored article into the editor', () async {
    articleRepository.articleByIdResult = DataSuccess(publishableArticle());

    await cubit.loadArticle('article-1');

    expect(cubit.state.status, ArticleEditorStatus.editing);
    expect(cubit.state.article.title, publishableArticle().title);
  });

  test('saves a new article as a draft', () async {
    cubit.startNewArticle();
    cubit.titleChanged('Working title');

    await cubit.save();

    expect(articleRepository.createCallCount, 1);
    expect(articleRepository.lastCreatedArticle?.status, ArticleStatus.draft);
    expect(cubit.state.status, ArticleEditorStatus.saved);
  });

  test('updates instead of creating when the article is already stored',
      () async {
    articleRepository.articleByIdResult = DataSuccess(publishableArticle());
    await cubit.loadArticle('article-1');

    cubit.titleChanged('A better title');
    await cubit.save();

    expect(articleRepository.updateCallCount, 1);
    expect(articleRepository.createCallCount, 0);
    expect(articleRepository.lastUpdatedArticle?.title, 'A better title');
  });

  test('reports the rules a draft breaks and stays in the editor', () async {
    cubit.startNewArticle();

    await cubit.save();

    expect(cubit.state.status, ArticleEditorStatus.failure);
    expect(
      cubit.state.validationErrors,
      contains(ArticleValidationError.titleRequired),
    );
    expect(articleRepository.createCallCount, 0);
  });

  test('publishes a new article in a single step', () async {
    writeCompleteArticle();
    await cubit.uploadThumbnail(thumbnail());

    await cubit.publish();

    expect(
      articleRepository.lastCreatedArticle?.status,
      ArticleStatus.published,
    );
    // Publishing reports its own state: it leads to the success screen,
    // while a saved draft just closes the editor.
    expect(cubit.state.status, ArticleEditorStatus.published);
  });

  test('refuses to publish an article without a cover image', () async {
    writeCompleteArticle();

    await cubit.publish();

    expect(cubit.state.status, ArticleEditorStatus.failure);
    expect(
      cubit.state.validationErrors,
      contains(ArticleValidationError.thumbnailRequired),
    );
    expect(articleRepository.createCallCount, 0);
  });

  group('picking a cover', () {
    test('uploads what was picked and attaches its url', () async {
      thumbnailRepository.uploadResult = const DataSuccess('https://cover.jpg');
      cubit.startNewArticle();

      await cubit.pickCover();

      expect(pickerRepository.pickCallCount, 1);
      expect(thumbnailRepository.uploadCallCount, 1);
      expect(cubit.state.article.thumbnailUrl, 'https://cover.jpg');
    });

    test('cancelling leaves the editor exactly as it was', () async {
      pickerRepository.willBeCancelled();
      cubit.startNewArticle();
      cubit.titleChanged('Working title');
      final before = cubit.state;

      await cubit.pickCover();

      expect(thumbnailRepository.uploadCallCount, 0);
      expect(cubit.state.article, before.article);
      expect(cubit.state.status, isNot(ArticleEditorStatus.failure));
    });

    test('an oversized image never reaches Cloud Storage', () async {
      pickerRepository.willPick(
        thumbnail(sizeInBytes: ArticleThumbnailEntity.maxSizeInBytes + 1),
      );
      cubit.startNewArticle();

      await cubit.pickCover();

      expect(cubit.state.status, ArticleEditorStatus.failure);
      expect(thumbnailRepository.uploadCallCount, 0);
    });
  });

  test('attaches the url returned by the upload', () async {
    thumbnailRepository.uploadResult = const DataSuccess('https://cover.jpg');
    cubit.startNewArticle();

    await cubit.uploadThumbnail(thumbnail());

    expect(cubit.state.article.thumbnailUrl, 'https://cover.jpg');
    expect(cubit.state.status, ArticleEditorStatus.editing);
  });

  test('never uploads an image the storage rules would reject', () async {
    cubit.startNewArticle();

    await cubit.uploadThumbnail(
      thumbnail(sizeInBytes: ArticleThumbnailEntity.maxSizeInBytes + 1),
    );

    expect(cubit.state.status, ArticleEditorStatus.failure);
    expect(thumbnailRepository.uploadCallCount, 0);
    expect(cubit.state.article.thumbnailUrl, isEmpty);
  });

  test('clears a previous failure as soon as the journalist types', () async {
    cubit.startNewArticle();
    await cubit.save();

    cubit.titleChanged('Working title');

    expect(cubit.state.status, ArticleEditorStatus.editing);
    expect(cubit.state.validationErrors, isEmpty);
    expect(cubit.state.error, isNull);
  });

  group('unsaved changes', () {
    test('an untouched new article has nothing to lose', () {
      cubit.startNewArticle();

      expect(cubit.state.hasUnsavedChanges, isFalse);
    });

    test('writing before the article has ever been saved counts', () {
      // The case autosave cannot cover: somebody who writes three paragraphs
      // before thinking of a title.
      cubit.startNewArticle();
      cubit.contentChanged('The depot doors open at 23:40.');

      expect(cubit.state.hasUnsavedChanges, isTrue);
    });

    test('saving clears it', () async {
      cubit.startNewArticle();
      cubit.titleChanged('Working title');

      await cubit.save();

      expect(cubit.state.hasUnsavedChanges, isFalse);
    });

    test('editing a published article counts, because autosave will not',
        () async {
      articleRepository.articleByIdResult = DataSuccess(
        publishableArticle(status: ArticleStatus.published),
      );
      await cubit.loadArticle('article-1');

      expect(cubit.state.hasUnsavedChanges, isFalse);

      cubit.contentChanged('A late correction');

      expect(cubit.state.hasUnsavedChanges, isTrue);
    });

    test('a loaded article starts even with what is stored', () async {
      articleRepository.articleByIdResult = DataSuccess(publishableArticle());

      await cubit.loadArticle('article-1');

      expect(cubit.state.hasUnsavedChanges, isFalse);
    });

    test('attaching a cover counts as a change', () async {
      thumbnailRepository.uploadResult = const DataSuccess('https://cover.jpg');
      cubit.startNewArticle();

      await cubit.pickCover();

      expect(cubit.state.hasUnsavedChanges, isTrue);
    });
  });

  group('autosave', () {
    late ArticleEditorCubit autosavingCubit;

    setUp(() {
      autosavingCubit = ArticleEditorCubit(
        GetArticleByIdUseCase(articleRepository),
        CreateArticleUseCase(articleRepository),
        UpdateArticleUseCase(articleRepository),
        PublishArticleUseCase(articleRepository),
        UploadArticleThumbnailUseCase(thumbnailRepository),
        PickArticleCoverUseCase(pickerRepository),
        journalistId: 'journalist-1',
        journalistName: 'Alex Rivera',
        autosaveDelay: const Duration(milliseconds: 5),
      );
    });

    tearDown(() => autosavingCubit.close());

    test('saves a draft on its own shortly after the journalist stops typing',
        () async {
      autosavingCubit.startNewArticle();
      autosavingCubit.titleChanged('Working title');

      await Future.delayed(const Duration(milliseconds: 30));

      expect(articleRepository.createCallCount, 1);
      expect(
        articleRepository.lastCreatedArticle?.status,
        ArticleStatus.draft,
      );
    });

    test('does not autosave a title that has not met the draft rules yet',
        () async {
      autosavingCubit.startNewArticle();
      // Title is still blank: `validateAsDraft()` is not empty yet.
      autosavingCubit.descriptionChanged('Not enough on its own');

      await Future.delayed(const Duration(milliseconds: 30));

      expect(articleRepository.createCallCount, 0);
    });

    test('reports an autosave apart from an explicit save', () async {
      autosavingCubit.startNewArticle();
      autosavingCubit.titleChanged('Working title');

      await Future.delayed(const Duration(milliseconds: 30));

      // The editor closes on `saved`; an autosave must not look like one, or
      // pausing to think would throw the journalist out of the article.
      expect(autosavingCubit.state.status, ArticleEditorStatus.autosaved);
    });

    test('an explicit save still reports saved, so the editor can close',
        () async {
      autosavingCubit.startNewArticle();
      autosavingCubit.titleChanged('Working title');

      await autosavingCubit.save();

      expect(autosavingCubit.state.status, ArticleEditorStatus.saved);
    });

    test('keeps what was typed while the autosave was in flight', () async {
      articleRepository.createResult = DataSuccess(
        publishableArticle(id: 'created-id').copyWith(title: 'Half a title'),
      );
      autosavingCubit.startNewArticle();
      autosavingCubit.titleChanged('Half a title');

      await Future.delayed(const Duration(milliseconds: 30));
      // The journalist kept typing while the write was travelling.
      autosavingCubit.titleChanged('Half a title, then the rest');

      expect(
        autosavingCubit.state.article.title,
        'Half a title, then the rest',
      );
      // ...and the id the backend assigned was still picked up, so the next
      // save updates instead of creating a second article.
      expect(autosavingCubit.state.article.id, 'created-id');
    });

    test('does not autosave over an already published article', () async {
      articleRepository.articleByIdResult = DataSuccess(
        publishableArticle(status: ArticleStatus.published),
      );
      await autosavingCubit.loadArticle('article-1');

      autosavingCubit.contentChanged('A late correction');

      await Future.delayed(const Duration(milliseconds: 30));

      expect(articleRepository.updateCallCount, 0);
    });

    test('a manual save cancels the pending autosave', () async {
      autosavingCubit.startNewArticle();
      autosavingCubit.titleChanged('Working title');

      await autosavingCubit.save();
      await Future.delayed(const Duration(milliseconds: 30));

      expect(articleRepository.createCallCount, 1);
    });
  });

  /// What the editor does while a write is already on its way.
  ///
  /// Every bug in this group came out of the same hole: busyness was read off
  /// `status`, and typing sets the status back to `editing`. A keystroke
  /// during a save therefore announced the editor idle while it was not.
  group('a save already in flight', () {
    /// A repository that holds its answer until the test lets it go, so the
    /// window during which a save is in flight can actually be entered.
    void holdTheNextSave() {
      articleRepository.createResult = null;
    }

    test('typing does not make the editor look idle', () async {
      writeCompleteArticle();

      final pending = cubit.save();
      expect(cubit.state.isBusy, isTrue);

      // Mid-write, the journalist carries on typing.
      cubit.contentChanged('The depot doors open at 23:40. It is cold.');

      // The status is back to `editing`, and the editor must still know it is
      // busy — this is what re-enabled Save and Publish mid-write.
      expect(cubit.state.status, ArticleEditorStatus.editing);
      expect(cubit.state.isSaving, isTrue);
      expect(cubit.state.isBusy, isTrue);

      await pending;
      expect(cubit.state.isSaving, isFalse);
    });

    test('a second save is refused rather than duplicating the article',
        () async {
      holdTheNextSave();
      writeCompleteArticle();

      final first = cubit.save();
      final second = cubit.save();

      await Future.wait([first, second]);

      // One article, not two. Two creates meant two rows in My articles for
      // one piece of writing.
      expect(articleRepository.createCallCount, 1);
    });

    test('publishing is refused while a save is running', () async {
      writeCompleteArticle();

      final saving = cubit.save();
      final publishing = cubit.publish();

      await Future.wait([saving, publishing]);

      expect(articleRepository.createCallCount, 1);
    });

    test('a failure hands the buttons back', () async {
      articleRepository.createResult =
          const DataFailed(ArticleNotStoredException());
      writeCompleteArticle();

      await cubit.save();

      // Leaving `isSaving` set is what left both buttons dead with no way out
      // of the editor except discarding the work.
      expect(cubit.state.status, ArticleEditorStatus.failure);
      expect(cubit.state.isSaving, isFalse);
      expect(cubit.state.isBusy, isFalse);
    });

    test('a refused publish hands the buttons back too', () async {
      cubit.startNewArticle();
      cubit.titleChanged('Only a title');

      // No description, no body, no cover: the publishing rules reject it.
      await cubit.publish();

      expect(cubit.state.validationErrors, isNotEmpty);
      expect(cubit.state.isBusy, isFalse);
    });

    test('an upload in flight also counts as busy', () async {
      cubit.startNewArticle();

      final uploading = cubit.uploadThumbnail(
        thumbnail(),
      );

      expect(cubit.state.isBusy, isTrue);

      await uploading;

      expect(cubit.state.isBusy, isFalse);
    });
  });

  /// Publishing something already public is not an operation.
  group('an article that is already published', () {
    test('is not offered publishing again', () async {
      articleRepository.articleByIdResult = DataSuccess(
        publishableArticle(status: ArticleStatus.published),
      );
      await cubit.loadArticle('article-1');

      expect(cubit.state.canPublish, isFalse);
    });

    test('a draft still is', () {
      writeCompleteArticle();

      expect(cubit.state.canPublish, isTrue);
    });
  });
}
