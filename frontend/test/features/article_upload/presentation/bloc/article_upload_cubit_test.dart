import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/services/analytics_service.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_draft_entity.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_upload_entity.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/draft_repository.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/clear_draft_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/increment_article_views_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/load_draft_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/save_draft_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/upload_article_thumbnail_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/upload_article_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/article_upload_cubit.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/article_upload_state.dart';

// ---------------------------------------------------------------------------
// Stubs
// ---------------------------------------------------------------------------

class _StubAnalytics implements AnalyticsService {
  final List<AnalyticsEvent> tracked = [];

  @override
  void trackEvent(AnalyticsEvent event, {Map<String, dynamic>? properties}) {
    tracked.add(event);
  }
}

class _StubArticleUploadRepository implements ArticleUploadRepository {
  ArticleUploadEntity? uploadResult;
  String? thumbnailResult;
  Exception? throwOnUpload;
  Exception? throwOnThumbnail;

  @override
  Future<ArticleUploadEntity> uploadArticle(ArticleUploadEntity article) async {
    if (throwOnUpload != null) throw throwOnUpload!;
    return uploadResult ?? article.copyWith(id: 'article-123');
  }

  @override
  Future<String> uploadThumbnail({
    required String localFilePath,
    required String authorId,
  }) async {
    if (throwOnThumbnail != null) throw throwOnThumbnail!;
    return thumbnailResult ?? 'https://example.com/thumb.jpg';
  }

  @override
  Future<List<ArticleUploadEntity>> getMyArticles(String authorId) async => [];

  @override
  Future<List<ArticleUploadEntity>> getAllArticles() async => [];

  @override
  Future<void> incrementArticleViews(String articleId) async {}
}

class _StubDraftRepository implements DraftRepository {
  ArticleDraftEntity? storedDraft;

  @override
  Future<void> saveDraft(ArticleDraftEntity draft) async {
    storedDraft = draft;
  }

  @override
  Future<ArticleDraftEntity?> loadDraft() async => storedDraft;

  @override
  Future<void> clearDraft() async {
    storedDraft = null;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ArticleUploadCubit _makeCubit({
  _StubArticleUploadRepository? repo,
  _StubDraftRepository? draftRepo,
  _StubAnalytics? analytics,
}) {
  final r = repo ?? _StubArticleUploadRepository();
  final d = draftRepo ?? _StubDraftRepository();
  final a = analytics ?? _StubAnalytics();
  return ArticleUploadCubit(
    UploadArticleUseCase(r),
    UploadArticleThumbnailUseCase(r),
    SaveDraftUseCase(d),
    LoadDraftUseCase(d),
    ClearDraftUseCase(d),
    IncrementArticleViewsUseCase(r),
    a,
  );
}

const _validTitle = 'A valid article title';
const _validContent =
    'This is a long enough content for the article to be valid. '
    'It needs at least fifty characters to pass validation.';
const _authorId = 'user-abc';
const _authorName = 'Test Author';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ArticleUploadCubit — initial state', () {
    test('starts as ArticleUploadInitial', () {
      final cubit = _makeCubit();
      expect(cubit.state, isA<ArticleUploadInitial>());
      cubit.close();
    });
  });

  group('ArticleUploadCubit — pickAndUploadThumbnail', () {
    test('emits ThumbnailLoading then ThumbnailReady on success', () async {
      final repo = _StubArticleUploadRepository()
        ..thumbnailResult = 'https://cdn.example.com/img.jpg';
      final cubit = _makeCubit(repo: repo);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ArticleUploadThumbnailLoading>(),
          isA<ArticleUploadThumbnailReady>(),
        ]),
      );

      await cubit.pickAndUploadThumbnail(
        localFilePath: '/tmp/photo.jpg',
        authorId: _authorId,
      );
      await expectation;

      expect(
        (cubit.state as ArticleUploadThumbnailReady).thumbnailUrl,
        'https://cdn.example.com/img.jpg',
      );
      cubit.close();
    });

    test('emits ThumbnailLoading then Failure on error', () async {
      final repo = _StubArticleUploadRepository()
        ..throwOnThumbnail = Exception('network error');
      final cubit = _makeCubit(repo: repo);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ArticleUploadThumbnailLoading>(),
          isA<ArticleUploadFailure>(),
        ]),
      );

      await cubit.pickAndUploadThumbnail(
        localFilePath: '/tmp/photo.jpg',
        authorId: _authorId,
      );
      await expectation;

      expect(
        (cubit.state as ArticleUploadFailure).message,
        contains('Failed to upload image'),
      );
      cubit.close();
    });
  });

  group('ArticleUploadCubit — submitArticle', () {
    test('emits Failure when no thumbnail has been uploaded', () async {
      final cubit = _makeCubit();

      final states = <ArticleUploadState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.submitArticle(
        title: _validTitle,
        content: _validContent,
        authorId: _authorId,
        authorName: _authorName,
        tags: [],
      );

      expect(states.single, isA<ArticleUploadFailure>());
      expect(
        (states.single as ArticleUploadFailure).message,
        contains('thumbnail'),
      );

      await sub.cancel();
      cubit.close();
    });

    test('emits Uploading then Success on happy path', () async {
      final now = DateTime.now();
      final expected = ArticleUploadEntity(
        id: 'article-123',
        title: _validTitle,
        content: _validContent,
        thumbnailUrl: 'https://cdn.example.com/img.jpg',
        authorId: _authorId,
        authorName: _authorName,
        createdAt: now,
        updatedAt: now,
        readTime: 1,
        tags: [],
        isPublished: true,
      );
      final repo = _StubArticleUploadRepository()
        ..thumbnailResult = 'https://cdn.example.com/img.jpg'
        ..uploadResult = expected;
      final cubit = _makeCubit(repo: repo);

      await cubit.pickAndUploadThumbnail(
        localFilePath: '/tmp/photo.jpg',
        authorId: _authorId,
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ArticleUploading>(),
          isA<ArticleUploadSuccess>(),
        ]),
      );

      await cubit.submitArticle(
        title: _validTitle,
        content: _validContent,
        authorId: _authorId,
        authorName: _authorName,
        tags: [],
      );
      await expectation;

      expect((cubit.state as ArticleUploadSuccess).article.id, 'article-123');
      cubit.close();
    });

    test('emits Uploading then Failure when repository throws', () async {
      final repo = _StubArticleUploadRepository()
        ..thumbnailResult = 'https://cdn.example.com/img.jpg'
        ..throwOnUpload = Exception('Firestore unavailable');
      final cubit = _makeCubit(repo: repo);

      await cubit.pickAndUploadThumbnail(
        localFilePath: '/tmp/photo.jpg',
        authorId: _authorId,
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ArticleUploading>(),
          isA<ArticleUploadFailure>(),
        ]),
      );

      await cubit.submitArticle(
        title: _validTitle,
        content: _validContent,
        authorId: _authorId,
        authorName: _authorName,
        tags: [],
      );
      await expectation;

      expect(
        (cubit.state as ArticleUploadFailure).message,
        contains('Failed to publish'),
      );
      cubit.close();
    });
  });

  group('ArticleUploadCubit — draft', () {
    test('loadExistingDraft returns null when no draft saved', () async {
      final cubit = _makeCubit();
      final draft = await cubit.loadExistingDraft();
      expect(draft, isNull);
      cubit.close();
    });

    test('scheduleDraftSave persists draft after debounce', () async {
      final draftRepo = _StubDraftRepository();
      final cubit = _makeCubit(draftRepo: draftRepo);

      cubit.scheduleDraftSave(
        title: _validTitle,
        content: _validContent,
        tags: [],
      );

      await Future.delayed(const Duration(milliseconds: 900));

      expect(draftRepo.storedDraft, isNotNull);
      expect(draftRepo.storedDraft!.title, _validTitle);
      cubit.close();
    });

    test('discardDraft clears stored draft', () async {
      final draftRepo = _StubDraftRepository()
        ..storedDraft = ArticleDraftEntity(
          title: 'Old draft',
          content: 'Old content',
          tags: [],
          updatedAt: DateTime.now(),
        );
      final cubit = _makeCubit(draftRepo: draftRepo);

      await cubit.discardDraft();

      expect(draftRepo.storedDraft, isNull);
      cubit.close();
    });
  });

  group('ArticleUploadCubit — recordArticleView', () {
    test('increments views only once per article', () async {
      int callCount = 0;
      final repo = _StubArticleUploadRepository();
      // Override to count calls
      final cubit = ArticleUploadCubit(
        UploadArticleUseCase(repo),
        UploadArticleThumbnailUseCase(repo),
        SaveDraftUseCase(_StubDraftRepository()),
        LoadDraftUseCase(_StubDraftRepository()),
        ClearDraftUseCase(_StubDraftRepository()),
        _CountingIncrementUseCase(repo, onCall: () => callCount++),
        _StubAnalytics(),
      );

      await cubit.recordArticleView('article-1');
      await cubit.recordArticleView('article-1');
      await cubit.recordArticleView('article-1');

      expect(callCount, 1);
      cubit.close();
    });
  });

  group('ArticleUploadCubit — analytics', () {
    test('tracks onStartCreate when notifyCreationStarted called', () {
      final analytics = _StubAnalytics();
      final cubit = _makeCubit(analytics: analytics);

      cubit.notifyCreationStarted();

      expect(analytics.tracked, contains(AnalyticsEvent.onStartCreate));
      cubit.close();
    });

    test('tracks onDraftDiscarded when discardDraft called', () async {
      final analytics = _StubAnalytics();
      final cubit = _makeCubit(analytics: analytics);

      await cubit.discardDraft();

      expect(analytics.tracked, contains(AnalyticsEvent.onDraftDiscarded));
      cubit.close();
    });
  });

  group('ArticleUploadCubit — reset', () {
    test('emits ArticleUploadInitial after reset', () async {
      final repo = _StubArticleUploadRepository()
        ..thumbnailResult = 'https://cdn.example.com/img.jpg';
      final cubit = _makeCubit(repo: repo);

      await cubit.pickAndUploadThumbnail(
        localFilePath: '/tmp/photo.jpg',
        authorId: _authorId,
      );
      expect(cubit.state, isA<ArticleUploadThumbnailReady>());

      cubit.reset();
      expect(cubit.state, isA<ArticleUploadInitial>());
      cubit.close();
    });
  });
}

// ---------------------------------------------------------------------------
// Helper subclass to count incrementArticleViews calls
// ---------------------------------------------------------------------------

class _CountingIncrementUseCase extends IncrementArticleViewsUseCase {
  final void Function() onCall;

  _CountingIncrementUseCase(super.repository, {required this.onCall});

  @override
  Future<void> call(String articleId) {
    onCall();
    return super.call(articleId);
  }
}
