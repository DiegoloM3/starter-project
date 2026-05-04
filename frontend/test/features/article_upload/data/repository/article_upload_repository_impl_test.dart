import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/local/draft_dao.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/local/image_processing_service.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/remote/article_storage_service.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/remote/articles_firestore_service.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/models/draft_article_model.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/models/journalist_article_model.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/repository/article_upload_repository_impl.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/draft_id_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/save_draft_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/toggle_favorite_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/update_article_params.dart';

class MockFirestoreService extends Mock implements ArticlesFirestoreService {}

class MockStorageService extends Mock implements ArticleStorageService {}

class MockImageService extends Mock implements ImageProcessingService {}

class MockDraftDao extends Mock implements DraftDao {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class FakeDraftArticleModel extends Fake implements DraftArticleModel {}

class FakeJournalistArticleModel extends Fake
    implements JournalistArticleModel {}

JournalistArticleModel _makeModel({
  String id = 'article-001',
  ArticleStatus status = ArticleStatus.published,
}) {
  final now = DateTime(2025, 1, 1, 12);
  return JournalistArticleModel(
    id: id,
    title: 'Test',
    description: 'Desc',
    content: 'Content',
    urlToImage: 'https://example.com/img.jpg',
    publishedAt: now,
    userId: 'user-123',
    userDisplayName: 'Alice',
    source: 'journalist',
    category: ArticleCategory.tech,
    tags: const ['flutter'],
    language: 'en',
    readingTimeMinutes: 1,
    status: status,
    createdAt: now,
    updatedAt: now,
    viewCount: 0,
    favoriteCount: 0,
  );
}

PublishArticleParams _makePublishParams({Uint8List? imageBytes, int? draftId}) {
  return PublishArticleParams(
    title: 'Test',
    description: 'Desc',
    content: 'Content',
    imageBytes: imageBytes ?? Uint8List.fromList([1, 2, 3]),
    userId: 'user-123',
    userDisplayName: 'Alice',
    category: ArticleCategory.tech,
    tags: const ['flutter'],
    language: 'en',
    draftId: draftId,
  );
}

void main() {
  late MockFirestoreService firestoreService;
  late MockStorageService storageService;
  late MockDraftDao draftDao;
  late MockFirebaseAuth firebaseAuth;
  late MockUser mockUser;
  late ArticleUploadRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(FakeDraftArticleModel());
    registerFallbackValue(FakeJournalistArticleModel());
  });

  setUp(() {
    firestoreService = MockFirestoreService();
    storageService = MockStorageService();
    draftDao = MockDraftDao();
    firebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    repo = ArticleUploadRepositoryImpl(
      firestoreService,
      storageService,
      draftDao,
      firebaseAuth,
    );
  });

  group('publish', () {
    test('happy path — services called in correct order, doc patched twice',
        () async {
      when(() => firebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockUser.uid).thenReturn('user-123');
      when(() => firestoreService.allocateArticleId()).thenReturn('article-001');
      when(() => firestoreService.createArticle(any())).thenAnswer((_) async {});
      when(() => storageService.uploadThumbnail(
            articleId: any(named: 'articleId'),
            bytes: any(named: 'bytes'),
            contentType: any(named: 'contentType'),
          )).thenAnswer((_) async => 'https://cdn.example.com/thumb.jpg');
      when(() => firestoreService.updateArticle(any(), any()))
          .thenAnswer((_) async {});

      final params = _makePublishParams();
      final result = await repo.publish(params);

      expect(result, isA<DataSuccess<JournalistArticleEntity>>());
      verifyInOrder([
        () => firestoreService.allocateArticleId(),
        () => firestoreService.createArticle(any()),
        () => storageService.uploadThumbnail(
              articleId: any(named: 'articleId'),
              bytes: any(named: 'bytes'),
              contentType: any(named: 'contentType'),
            ),
        () => firestoreService.updateArticle(any(), any()),
      ]);
    });

    test('when draftId is present, draft is deleted after publish', () async {
      when(() => firebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockUser.uid).thenReturn('user-123');
      when(() => firestoreService.allocateArticleId()).thenReturn('article-001');
      when(() => firestoreService.createArticle(any())).thenAnswer((_) async {});
      when(() => storageService.uploadThumbnail(
            articleId: any(named: 'articleId'),
            bytes: any(named: 'bytes'),
            contentType: any(named: 'contentType'),
          )).thenAnswer((_) async => 'https://cdn.example.com/thumb.jpg');
      when(() => firestoreService.updateArticle(any(), any()))
          .thenAnswer((_) async {});
      when(() => draftDao.deleteDraft(any())).thenAnswer((_) async {});

      final params = _makePublishParams(draftId: 42);
      await repo.publish(params);

      verify(() => draftDao.deleteDraft(42)).called(1);
    });

    test('empty imageBytes returns DataFailed(ValidationException)', () async {
      when(() => firebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.isAnonymous).thenReturn(false);

      final params = _makePublishParams(imageBytes: Uint8List(0));
      final result = await repo.publish(params);

      expect(result, isA<DataFailed<JournalistArticleEntity>>());
      expect(result.error, isA<ValidationException>());
      verifyNever(() => firestoreService.allocateArticleId());
    });

    test('anonymous user returns DataFailed(AuthException)', () async {
      when(() => firebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.isAnonymous).thenReturn(true);

      final result = await repo.publish(_makePublishParams());

      expect(result, isA<DataFailed<JournalistArticleEntity>>());
      expect(result.error, isA<AuthException>());
      verifyNever(() => firestoreService.allocateArticleId());
    });

    test('null currentUser returns DataFailed(AuthException)', () async {
      when(() => firebaseAuth.currentUser).thenReturn(null);

      final result = await repo.publish(_makePublishParams());

      expect(result, isA<DataFailed<JournalistArticleEntity>>());
      expect(result.error, isA<AuthException>());
    });

    test('storage upload failure patches doc to upload_failed and returns DataFailed',
        () async {
      when(() => firebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockUser.uid).thenReturn('user-123');
      when(() => firestoreService.allocateArticleId()).thenReturn('article-001');
      when(() => firestoreService.createArticle(any())).thenAnswer((_) async {});
      when(() => storageService.uploadThumbnail(
            articleId: any(named: 'articleId'),
            bytes: any(named: 'bytes'),
            contentType: any(named: 'contentType'),
          )).thenThrow(const StorageException(message: 'Upload failed'));
      when(() => firestoreService.updateArticle(any(), any()))
          .thenAnswer((_) async {});

      final result = await repo.publish(_makePublishParams());

      expect(result, isA<DataFailed<JournalistArticleEntity>>());
      expect(result.error, isA<StorageException>());
      final updateCalls = verify(
              () => firestoreService.updateArticle(any(), captureAny()))
          .captured;
      expect(
        updateCalls.whereType<Map<String, dynamic>>().any(
              (m) => m['status'] == 'upload_failed',
            ),
        isTrue,
      );
    });
  });

  group('update', () {
    test('without new image — only updateArticle called', () async {
      when(() => firestoreService.updateArticle(any(), any()))
          .thenAnswer((_) async {});

      final params = UpdateArticleParams(
        articleId: 'article-001',
        title: 'New Title',
        description: 'Desc',
        content: 'Content',
        category: ArticleCategory.tech,
        tags: const [],
        language: 'en',
      );
      final result = await repo.update(params);

      expect(result, isA<DataSuccess<JournalistArticleEntity>>());
      verify(() => firestoreService.updateArticle('article-001', any()))
          .called(1);
      verifyNever(() => storageService.uploadThumbnail(
          articleId: any(named: 'articleId'),
          bytes: any(named: 'bytes'),
          contentType: any(named: 'contentType')));
    });

    test('with new image — upload then patch sequence', () async {
      when(() => storageService.uploadThumbnail(
            articleId: any(named: 'articleId'),
            bytes: any(named: 'bytes'),
            contentType: any(named: 'contentType'),
          )).thenAnswer((_) async => 'https://cdn.example.com/new.jpg');
      when(() => firestoreService.updateArticle(any(), any()))
          .thenAnswer((_) async {});

      final params = UpdateArticleParams(
        articleId: 'article-001',
        title: 'New Title',
        description: 'Desc',
        content: 'Content',
        newImageBytes: Uint8List.fromList([1, 2, 3]),
        category: ArticleCategory.tech,
        tags: const [],
        language: 'en',
      );
      final result = await repo.update(params);

      expect(result, isA<DataSuccess<JournalistArticleEntity>>());
      verifyInOrder([
        () => storageService.uploadThumbnail(
              articleId: any(named: 'articleId'),
              bytes: any(named: 'bytes'),
              contentType: any(named: 'contentType'),
            ),
        () => firestoreService.updateArticle(any(), any()),
      ]);
    });
  });

  group('delete', () {
    test('happy path — soft delete: firestore deleteArticle called, storage NOT touched', () async {
      when(() => firestoreService.deleteArticle(any()))
          .thenAnswer((_) async {});

      final result =
          await repo.delete(const DeleteArticleParams(articleId: 'article-001'));

      expect(result, isA<DataSuccess<void>>());
      verify(() => firestoreService.deleteArticle('article-001')).called(1);
      verifyNever(() => storageService.deleteThumbnail(any()));
    });
  });

  group('toggleFavorite', () {
    test('happy path — firestore service called with correct args', () async {
      when(() => firebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockUser.uid).thenReturn('user-abc');
      when(() => firestoreService.toggleFavorite(
            articleId: any(named: 'articleId'),
            userId: any(named: 'userId'),
            currentlyFavorited: any(named: 'currentlyFavorited'),
          )).thenAnswer((_) async {});

      final result = await repo.toggleFavorite(
        const ToggleFavoriteParams(
            articleId: 'article-001', currentlyFavorited: false),
      );

      expect(result, isA<DataSuccess<void>>());
      verify(() => firestoreService.toggleFavorite(
            articleId: 'article-001',
            userId: 'user-abc',
            currentlyFavorited: false,
          )).called(1);
    });

    test('anonymous user returns DataFailed(AuthException)', () async {
      when(() => firebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.isAnonymous).thenReturn(true);

      final result = await repo.toggleFavorite(
        const ToggleFavoriteParams(
            articleId: 'article-001', currentlyFavorited: false),
      );

      expect(result, isA<DataFailed<void>>());
      expect(result.error, isA<AuthException>());
      verifyNever(() => firestoreService.toggleFavorite(
          articleId: any(named: 'articleId'),
          userId: any(named: 'userId'),
          currentlyFavorited: any(named: 'currentlyFavorited')));
    });
  });

  group('saveDraft', () {
    test('returns DataSuccess with the inserted draftId', () async {
      when(() => draftDao.upsertDraft(any())).thenAnswer((_) async => 7);

      final params = const SaveDraftParams(
        title: 'Draft',
        description: '',
        content: '',
        tags: [],
        language: 'en',
      );
      final result = await repo.saveDraft(params);

      expect(result, isA<DataSuccess<int>>());
      expect(result.data, equals(7));
      final captured =
          verify(() => draftDao.upsertDraft(captureAny())).captured;
      expect(captured.first, isA<DraftArticleModel>());
    });
  });

  group('watchDrafts', () {
    test('streams drafts from DAO', () async {
      when(() => draftDao.watchDrafts()).thenAnswer((_) => Stream.value([]));

      final stream = repo.watchDrafts();
      final result = await stream.first;

      expect(result, isEmpty);
    });
  });

  group('deleteDraft', () {
    test('calls draftDao.deleteDraft with the correct id', () async {
      when(() => draftDao.deleteDraft(any())).thenAnswer((_) async {});

      final result =
          await repo.deleteDraft(const DraftIdParams(draftId: 99));

      expect(result, isA<DataSuccess<void>>());
      verify(() => draftDao.deleteDraft(99)).called(1);
    });
  });

  group('getDraftById', () {
    test('happy path — returns DataSuccess with entity when draft exists',
        () async {
      final model = DraftArticleModel(
        draftId: 7,
        title: 'Draft title',
        description: 'Draft desc',
        content: 'Draft content',
        tagsRaw: 'flutter,dart',
        language: 'en',
        lastSavedAtMillis: 1000,
      );
      when(() => draftDao.getDraft(7)).thenAnswer((_) async => model);

      final result = await repo.getDraftById(7);

      expect(result, isA<DataSuccess<DraftArticleEntity?>>());
      expect(result.data?.id, equals(7));
      expect(result.data?.title, equals('Draft title'));
    });

    test('not-found — returns DataSuccess(null) when draft absent', () async {
      when(() => draftDao.getDraft(99)).thenAnswer((_) async => null);

      final result = await repo.getDraftById(99);

      expect(result, isA<DataSuccess<DraftArticleEntity?>>());
      expect(result.data, isNull);
    });
  });

  group('stream proxies', () {
    test('watchByAuthor maps models to entities', () async {
      final model = _makeModel();
      when(() => firestoreService.watchByAuthor(any()))
          .thenAnswer((_) => Stream.value([model]));

      final entities = await repo.watchByAuthor('user-123').first;

      expect(entities.length, equals(1));
      expect(entities.first, isA<JournalistArticleEntity>());
    });

    test('watchCommunityFeed maps models to entities', () async {
      final model = _makeModel();
      when(() => firestoreService.watchCommunityFeed(limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.value([model]));

      final entities = await repo.watchCommunityFeed().first;

      expect(entities.length, equals(1));
      expect(entities.first, isA<JournalistArticleEntity>());
    });

    test('watchById maps model to entity, passes null through', () async {
      when(() => firestoreService.watchArticleById(any()))
          .thenAnswer((_) => Stream.value(null));

      final entity = await repo.watchById('article-001').first;

      expect(entity, isNull);
    });
  });
}
