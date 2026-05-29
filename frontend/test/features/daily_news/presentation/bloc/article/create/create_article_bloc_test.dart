import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_event.dart';


import '../../../../../../helpers/mock_classes.dart';
import '../../../../../../helpers/register_fallback_values.dart';
import '../../../../../../helpers/test_fixtures.dart';

void main() {
  late CreateArticleBloc bloc;
  late MockCreateArticleUseCase mockCreate;
  late MockUpdateArticleUseCase mockUpdate;
  late MockUploadThumbnailUseCase mockUpload;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockCreate = MockCreateArticleUseCase();
    mockUpdate = MockUpdateArticleUseCase();
    mockUpload = MockUploadThumbnailUseCase();
    bloc = CreateArticleBloc(
      mockCreate,
      mockUpdate,
      mockUpload,
      authorId: tUserId,
      authorName: tAuthorName,
    );
  });

  tearDown(() => bloc.close());

  group('initial state', () {
    test('has empty fields and draft status', () {
      final state = bloc.state;
      expect(state.title, '');
      expect(state.description, '');
      expect(state.content, '');
      expect(state.status, ArticleStatus.draft);
      expect(state.articleId, isNull);
      expect(state.isSaving, isFalse);
      expect(state.isPublishing, isFalse);
      expect(state.isPublished, isFalse);
      expect(state.error, isNull);
      expect(state.hasContent, isFalse);
      expect(state.canPublish, isFalse);
    });
  });

  group('LoadExistingDraft', () {
    test('populates state from article entity', () async {
      final article = testArticle(
        title: 'Draft Title',
        description: 'Draft Desc',
        content: 'Draft Content',
      );

      bloc.add(LoadExistingDraft(article));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.title, 'Draft Title');
      expect(bloc.state.description, 'Draft Desc');
      expect(bloc.state.content, 'Draft Content');
      expect(bloc.state.articleId, tArticleId);
      expect(bloc.state.status, ArticleStatus.draft);
    });
  });

  group('text field changes', () {
    test('TitleChanged updates title', () async {
      bloc.add(const TitleChanged('New Title'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.title, 'New Title');
      expect(bloc.state.hasContent, isTrue);
    });

    test('DescriptionChanged updates description', () async {
      bloc.add(const DescriptionChanged('New Description'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.description, 'New Description');
    });

    test('ContentChanged updates content and recalculates reading time',
        () async {
      final longContent = List.generate(530, (i) => 'word').join(' ');
      bloc.add(ContentChanged(longContent));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.content, longContent);
      // 530 words / 100 wpm -> ceil = 6
      expect(bloc.state.readingTimeMinutes, 6);
      expect(bloc.state.hasContent, isTrue);
    });

    test('ContentChanged with short content sets 1 min reading time',
        () async {
      bloc.add(const ContentChanged('Short'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.readingTimeMinutes, 1);
    });
  });

  group('thumbnail', () {
    test('ThumbnailSelected sets selectedImagePath', () async {
      bloc.add(const ThumbnailSelected('/path/to/image.jpg'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.selectedImagePath, '/path/to/image.jpg');
    });

    test('ThumbnailRemoved clears image and thumbnail URL', () async {
      bloc.add(const ThumbnailSelected('/path/to/image.jpg'));
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(const ThumbnailRemoved());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.selectedImagePath, isNull);
      expect(bloc.state.thumbnailUrl, isNull);
    });
  });

  group('SaveDraft', () {
    test('creates new article when articleId is null', () async {
      final createdArticle = testArticle(id: 'new-id');
      when(() => mockCreate(params: any(named: 'params')))
          .thenAnswer((_) async => DataSuccess(createdArticle));

      bloc.add(const TitleChanged('My Draft'));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const SaveDraft());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.articleId, 'new-id');
      expect(bloc.state.isSaving, isFalse);
      verify(() => mockCreate(params: any(named: 'params')))
          .called(greaterThanOrEqualTo(1));
    });

    test('updates existing article when articleId is set', () async {
      final existingArticle = testArticle(id: 'existing-id');
      when(() => mockCreate(params: any(named: 'params')))
          .thenAnswer((_) async => DataSuccess(existingArticle));
      when(() => mockUpdate(params: any(named: 'params')))
          .thenAnswer((_) async => DataSuccess(existingArticle));

      bloc.add(LoadExistingDraft(existingArticle));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const SaveDraft());
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockUpdate(params: any(named: 'params')))
          .called(greaterThanOrEqualTo(1));
      verifyNever(() => mockCreate(params: any(named: 'params')));
    });

    test('does nothing when content is empty', () async {
      bloc.add(const SaveDraft());
      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(() => mockCreate(params: any(named: 'params')));
      verifyNever(() => mockUpdate(params: any(named: 'params')));
    });

    test('sets error when create fails', () async {
      const error = AppException(message: 'create failed', code: 'err');
      when(() => mockCreate(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(error));

      bloc.add(const TitleChanged('Title'));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const SaveDraft());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.error, isNotNull);
      expect(bloc.state.isSaving, isFalse);
    });
  });

  group('PublishArticle', () {
    test('creates, uploads thumbnail, and publishes', () async {
      final createdArticle = testArticle(id: 'pub-id');
      when(() => mockCreate(params: any(named: 'params')))
          .thenAnswer((_) async => DataSuccess(createdArticle));
      when(() => mockUpload(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(tThumbnailUrl));
      when(() => mockUpdate(params: any(named: 'params')))
          .thenAnswer((_) async => DataSuccess(createdArticle));

      bloc.add(const TitleChanged('Title'));
      bloc.add(const DescriptionChanged('Description'));
      bloc.add(const ContentChanged('Content body'));
      bloc.add(const ThumbnailSelected('/path/thumb.jpg'));
      await Future.delayed(const Duration(milliseconds: 100));

      bloc.add(const PublishArticle());
      await Future.delayed(const Duration(milliseconds: 300));

      expect(bloc.state.status, ArticleStatus.published);
      expect(bloc.state.isPublished, isTrue);
      expect(bloc.state.isPublishing, isFalse);
    });

    test('sets error when create fails during publish', () async {
      const error = AppException(message: 'fail', code: 'err');
      when(() => mockCreate(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(error));

      bloc.add(const TitleChanged('Title'));
      bloc.add(const DescriptionChanged('Description'));
      bloc.add(const ContentChanged('Content body'));
      await Future.delayed(const Duration(milliseconds: 100));

      bloc.add(const PublishArticle());
      await Future.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.error, isNotNull);
      expect(bloc.state.isPublishing, isFalse);
      expect(bloc.state.isPublished, isFalse);
    });

    test('does nothing when canPublish is false (missing fields)', () async {
      // Only set title, missing description and content
      bloc.add(const TitleChanged('Title'));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const PublishArticle());
      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(() => mockCreate(params: any(named: 'params')));
      expect(bloc.state.isPublishing, isFalse);
    });
  });

  group('ArchiveArticle', () {
    test('transitions published article to archived', () async {
      final publishedArticle = testArticle(
        id: 'arch-id',
        status: ArticleStatus.published,
      );
      when(() => mockUpdate(params: any(named: 'params')))
          .thenAnswer((_) async => DataSuccess(publishedArticle));

      bloc.add(LoadExistingDraft(publishedArticle));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const ArchiveArticle());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, ArticleStatus.archived);
    });

    test('does nothing when status is draft (invalid transition)', () async {
      bloc.add(const TitleChanged('Draft'));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const ArchiveArticle());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.status, ArticleStatus.draft);
      verifyNever(() => mockUpdate(params: any(named: 'params')));
    });

    test('sets error when archive update fails', () async {
      const error = AppException(message: 'archive failed', code: 'err');
      final publishedArticle = testArticle(
        id: 'fail-id',
        status: ArticleStatus.published,
      );
      when(() => mockUpdate(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(error));

      bloc.add(LoadExistingDraft(publishedArticle));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const ArchiveArticle());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.error, isNotNull);
      expect(bloc.state.isPublishing, isFalse);
    });
  });
}
