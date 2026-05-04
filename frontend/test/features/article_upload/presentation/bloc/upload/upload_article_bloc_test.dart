import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/draft_id_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/save_draft_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/get_draft_by_id.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/save_draft.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/update_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/local/image_processing_service.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_state.dart';

class MockPublishArticleUseCase extends Mock implements PublishArticleUseCase {}

class MockSaveDraftUseCase extends Mock implements SaveDraftUseCase {}

class MockGetDraftByIdUseCase extends Mock implements GetDraftByIdUseCase {}

class MockUpdateArticleUseCase extends Mock implements UpdateArticleUseCase {}

class MockImageProcessingService extends Mock implements ImageProcessingService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockPublishArticleUseCase publishUseCase;
  late MockSaveDraftUseCase saveDraftUseCase;
  late MockGetDraftByIdUseCase getDraftByIdUseCase;
  late MockUpdateArticleUseCase updateUseCase;
  late MockImageProcessingService imageService;
  late MockFirebaseAuth firebaseAuth;
  late MockUser mockUser;

  final fakeBytes = Uint8List.fromList([1, 2, 3]);

  setUp(() {
    publishUseCase = MockPublishArticleUseCase();
    saveDraftUseCase = MockSaveDraftUseCase();
    getDraftByIdUseCase = MockGetDraftByIdUseCase();
    updateUseCase = MockUpdateArticleUseCase();
    imageService = MockImageProcessingService();
    firebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    registerFallbackValue(PublishArticleParams(
      title: '',
      description: '',
      content: '',
      imageBytes: Uint8List(0),
      userId: '',
      userDisplayName: '',
      category: ArticleCategory.other,
      tags: [],
      language: 'en',
    ));
    registerFallbackValue(const SaveDraftParams(
      title: '',
      description: '',
      content: '',
      tags: [],
      language: 'en',
    ));
    registerFallbackValue(const DraftIdParams(draftId: 0));
    registerFallbackValue(const UpdateArticleParams(
      articleId: '',
      title: '',
      description: '',
      content: '',
      category: ArticleCategory.other,
      tags: [],
      language: 'en',
    ));
  });

  UploadArticleBloc buildBloc() => UploadArticleBloc(
        publishUseCase,
        saveDraftUseCase,
        imageService,
        firebaseAuth,
        getDraftByIdUseCase,
        updateUseCase,
      );

  group('UploadArticleBloc', () {
    test('initial state is empty UploadArticleState', () {
      final bloc = buildBloc();
      expect(bloc.state, const UploadArticleState());
      bloc.close();
    });

    blocTest<UploadArticleBloc, UploadArticleState>(
      'TitleChangedEvent updates title in state',
      build: buildBloc,
      act: (b) => b.add(const TitleChangedEvent('Hello World')),
      expect: () => [
        isA<UploadArticleState>()
            .having((s) => s.title, 'title', 'Hello World'),
      ],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'DescriptionChangedEvent updates description in state',
      build: buildBloc,
      act: (b) => b.add(const DescriptionChangedEvent('A good description for my article')),
      expect: () => [
        isA<UploadArticleState>()
            .having((s) => s.description, 'description', 'A good description for my article'),
      ],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'ContentChangedEvent updates content in state',
      build: buildBloc,
      act: (b) => b.add(const ContentChangedEvent('Some article content here')),
      expect: () => [
        isA<UploadArticleState>()
            .having((s) => s.content, 'content', 'Some article content here'),
      ],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'StartNewArticleEvent resets to initial state',
      build: buildBloc,
      seed: () => const UploadArticleState(title: 'old title', content: 'old content'),
      act: (b) => b.add(const StartNewArticleEvent()),
      expect: () => [const UploadArticleState()],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'canPublish is false until all required fields are filled',
      build: buildBloc,
      act: (b) {
        b.add(const TitleChangedEvent('A valid title'));
        b.add(const DescriptionChangedEvent('A valid description that is long enough'));
        b.add(const ContentChangedEvent('Valid content that is more than fifty characters long for testing'));
        b.add(const CategoryChangedEvent(ArticleCategory.tech));
      },
      verify: (b) {
        expect(b.state.canPublish, isFalse,
            reason: 'canPublish requires thumbnail too');
      },
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'PublishEvent emits isPublishing then isPublished on success',
      build: () {
        when(() => firebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('uid-123');
        when(() => mockUser.isAnonymous).thenReturn(false);
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);

        final article = JournalistArticleEntity(
          id: 'art-1',
          title: 'A valid title here',
          description: 'A valid description that is long enough',
          content: 'Valid content that is more than fifty characters long for testing purposes',
          urlToImage: 'https://example.com/thumb.jpg',
          publishedAt: DateTime(2024),
          userId: 'uid-123',
          userDisplayName: 'Test User',
          source: 'journalist',
          category: ArticleCategory.tech,
          tags: [],
          language: 'en',
          readingTimeMinutes: 1,
          status: ArticleStatus.published,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
          viewCount: 0,
          favoriteCount: 0,
        );
        when(() => publishUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => DataSuccess(article));
        return buildBloc();
      },
      seed: () => UploadArticleState(
        title: 'A valid title here',
        description: 'A valid description that is long enough',
        content: 'Valid content that is more than fifty characters long for testing purposes',
        compressedBytes: fakeBytes,
        category: ArticleCategory.tech,
        tags: const ['flutter'],
      ),
      act: (b) => b.add(const PublishEvent()),
      expect: () => [
        isA<UploadArticleState>().having((s) => s.isPublishing, 'isPublishing', true),
        isA<UploadArticleState>()
            .having((s) => s.isPublished, 'isPublished', true)
            .having((s) => s.isPublishing, 'isPublishing', false),
      ],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'PublishEvent without thumbnail emits thumbnail-required validation',
      build: () {
        when(() => firebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('uid-123');
        when(() => mockUser.isAnonymous).thenReturn(false);
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);
        return buildBloc();
      },
      seed: () => const UploadArticleState(
        title: 'A valid title here',
        description: 'A valid description that is long enough',
        content:
            'Valid content that is more than fifty characters long for testing purposes',
        category: ArticleCategory.tech,
      ),
      act: (b) => b.add(const PublishEvent()),
      expect: () => [
        isA<UploadArticleState>().having(
          (s) => s.error?.code,
          'error.code',
          'thumbnail-required',
        ),
      ],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'PublishEvent with short title emits title-too-short validation',
      build: buildBloc,
      seed: () => const UploadArticleState(
        title: 'Hi',
        description: 'A valid description that is long enough',
        content:
            'Valid content that is more than fifty characters long for testing purposes',
        category: ArticleCategory.tech,
      ),
      act: (b) => b.add(const PublishEvent()),
      expect: () => [
        isA<UploadArticleState>().having(
          (s) => s.error?.code,
          'error.code',
          'title-too-short',
        ),
      ],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'PublishEvent without tags emits tags-required validation',
      build: () {
        when(() => firebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('uid-123');
        when(() => mockUser.isAnonymous).thenReturn(false);
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);
        return buildBloc();
      },
      seed: () => UploadArticleState(
        title: 'A valid title here',
        description: 'A valid description that is long enough',
        content:
            'Valid content that is more than fifty characters long for testing purposes',
        compressedBytes: fakeBytes,
        category: ArticleCategory.tech,
      ),
      act: (b) => b.add(const PublishEvent()),
      expect: () => [
        isA<UploadArticleState>().having(
          (s) => s.error?.code,
          'error.code',
          'tags-required',
        ),
      ],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'PublishEvent without category emits category-required validation',
      build: () {
        when(() => firebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('uid-123');
        when(() => mockUser.isAnonymous).thenReturn(false);
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);
        return buildBloc();
      },
      seed: () => UploadArticleState(
        title: 'A valid title here',
        description: 'A valid description that is long enough',
        content:
            'Valid content that is more than fifty characters long for testing purposes',
        compressedBytes: fakeBytes,
      ),
      act: (b) => b.add(const PublishEvent()),
      expect: () => [
        isA<UploadArticleState>().having(
          (s) => s.error?.code,
          'error.code',
          'category-required',
        ),
      ],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'PublishEvent with anonymous user emits AuthException error',
      build: () {
        when(() => firebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.isAnonymous).thenReturn(true);
        return buildBloc();
      },
      seed: () => UploadArticleState(
        title: 'A valid title here',
        description: 'A valid description that is long enough',
        content: 'Valid content that is more than fifty characters long for testing purposes',
        compressedBytes: fakeBytes,
        category: ArticleCategory.tech,
        tags: const ['flutter'],
      ),
      act: (b) => b.add(const PublishEvent()),
      expect: () => [
        isA<UploadArticleState>().having(
          (s) => s.error,
          'error',
          isA<AuthException>(),
        ),
      ],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'PublishEvent with null user emits AuthException error',
      build: () {
        when(() => firebaseAuth.currentUser).thenReturn(null);
        return buildBloc();
      },
      seed: () => UploadArticleState(
        title: 'A valid title here',
        description: 'A valid description that is long enough',
        content: 'Valid content that is more than fifty characters long for testing purposes',
        compressedBytes: fakeBytes,
        category: ArticleCategory.tech,
        tags: const ['flutter'],
      ),
      act: (b) => b.add(const PublishEvent()),
      expect: () => [
        isA<UploadArticleState>().having(
          (s) => s.error,
          'error',
          isA<AuthException>(),
        ),
      ],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'SaveDraftManuallyEvent persists draft and stores returned draftId',
      build: () {
        when(() => saveDraftUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => const DataSuccess(7));
        return buildBloc();
      },
      seed: () => const UploadArticleState(title: 'My Draft Title'),
      act: (b) => b.add(const SaveDraftManuallyEvent()),
      expect: () => [
        isA<UploadArticleState>()
            .having((s) => s.lastSavedAt, 'lastSavedAt', isNotNull)
            .having((s) => s.draftId, 'draftId', equals(7)),
      ],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'AutoSave skips write when all fields are empty',
      build: () => buildBloc(),
      act: (b) => b.add(const SaveDraftManuallyEvent()),
      expect: () => [],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'LoadDraftEvent prefills state from draft',
      build: () {
        final draft = DraftArticleEntity(
          id: 42,
          title: 'Draft Title',
          description: 'Draft description that is long',
          content: 'Draft content that is long enough',
          category: ArticleCategory.tech,
          tags: const ['flutter'],
          language: 'es',
          lastSavedAt: DateTime(2026, 1, 1),
        );
        when(() => getDraftByIdUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => DataSuccess(draft));
        return buildBloc();
      },
      act: (b) => b.add(const LoadDraftEvent(42)),
      expect: () => [
        isA<UploadArticleState>()
            .having((s) => s.draftId, 'draftId', equals(42))
            .having((s) => s.title, 'title', equals('Draft Title'))
            .having((s) => s.category, 'category', equals(ArticleCategory.tech))
            .having((s) => s.language, 'language', equals('es')),
      ],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'LoadDraftEvent with non-existent draftId leaves state unchanged',
      build: () {
        when(() => getDraftByIdUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => const DataSuccess(null));
        return buildBloc();
      },
      act: (b) => b.add(const LoadDraftEvent(999)),
      expect: () => [],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'LoadArticleForEditEvent populates state with article fields and sets editingArticleId',
      build: buildBloc,
      act: (b) {
        final article = JournalistArticleEntity(
          id: 'art-42',
          title: 'Existing Article',
          description: 'A description that is long enough',
          content: 'Content that is definitely more than fifty characters long here',
          urlToImage: 'https://example.com/thumb.jpg',
          publishedAt: DateTime(2025),
          userId: 'uid-1',
          userDisplayName: 'Alice',
          source: 'journalist',
          category: ArticleCategory.tech,
          tags: const ['flutter', 'dart'],
          language: 'es',
          readingTimeMinutes: 1,
          status: ArticleStatus.published,
          createdAt: DateTime(2025),
          updatedAt: DateTime(2025),
          viewCount: 0,
          favoriteCount: 0,
        );
        b.add(LoadArticleForEditEvent(article));
      },
      expect: () => [
        isA<UploadArticleState>()
            .having((s) => s.editingArticleId, 'editingArticleId', equals('art-42'))
            .having((s) => s.title, 'title', equals('Existing Article'))
            .having((s) => s.category, 'category', equals(ArticleCategory.tech))
            .having((s) => s.language, 'language', equals('es'))
            .having((s) => s.compressedBytes, 'compressedBytes', isNull),
      ],
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'In edit mode, canPublish is true without compressedBytes',
      build: buildBloc,
      seed: () => const UploadArticleState(
        editingArticleId: 'art-42',
        title: 'A valid title here',
        description: 'A valid description that is long enough',
        content: 'Valid content that is more than fifty characters long for testing purposes',
        category: ArticleCategory.tech,
        tags: ['flutter'],
      ),
      verify: (b) {
        expect(b.state.canPublish, isTrue,
            reason: 'edit mode does not require new compressedBytes');
      },
    );

    blocTest<UploadArticleBloc, UploadArticleState>(
      'PublishEvent in edit mode calls UpdateArticleUseCase, not PublishArticleUseCase',
      build: () {
        when(() => firebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('uid-123');
        when(() => mockUser.isAnonymous).thenReturn(false);
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);

        final article = JournalistArticleEntity(
          id: 'art-42',
          title: 'Updated Article Title',
          description: 'A valid description that is long enough',
          content: 'Valid content that is more than fifty characters long for testing purposes',
          urlToImage: 'https://example.com/thumb.jpg',
          publishedAt: DateTime(2025),
          userId: 'uid-123',
          userDisplayName: 'Test User',
          source: 'journalist',
          category: ArticleCategory.tech,
          tags: const ['flutter'],
          language: 'en',
          readingTimeMinutes: 1,
          status: ArticleStatus.published,
          createdAt: DateTime(2025),
          updatedAt: DateTime(2025),
          viewCount: 0,
          favoriteCount: 0,
        );
        when(() => updateUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => DataSuccess(article));
        return buildBloc();
      },
      seed: () => const UploadArticleState(
        editingArticleId: 'art-42',
        title: 'Updated Article Title',
        description: 'A valid description that is long enough',
        content: 'Valid content that is more than fifty characters long for testing purposes',
        category: ArticleCategory.tech,
        tags: ['flutter'],
      ),
      act: (b) => b.add(const PublishEvent()),
      expect: () => [
        isA<UploadArticleState>().having((s) => s.isPublishing, 'isPublishing', true),
        isA<UploadArticleState>()
            .having((s) => s.isPublished, 'isPublished', true)
            .having((s) => s.isPublishing, 'isPublishing', false),
      ],
      verify: (_) {
        verifyNever(() => publishUseCase.call(params: any(named: 'params')));
        verify(() => updateUseCase.call(params: any(named: 'params'))).called(1);
      },
    );
  });
}
