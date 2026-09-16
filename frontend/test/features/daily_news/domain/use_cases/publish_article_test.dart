import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/publish_article.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockUserArticleRepository userArticles;
  late MockThumbnailStorageRepository storage;
  late MockAuthRepository auth;
  late PublishArticleUseCase useCase;

  final draft = buildDraft();
  final image = buildImage();
  final created = buildUserArticle(authorId: user.id);

  setUpAll(() {
    registerFallbackValue(draft);
    registerFallbackValue(image);
  });

  setUp(() {
    userArticles = MockUserArticleRepository();
    storage = MockThumbnailStorageRepository();
    auth = MockAuthRepository();
    useCase = PublishArticleUseCase(userArticles, storage, auth);
    when(() => auth.currentUser).thenReturn(user);
  });

  When<Future<DataState<ArticleEntity>>> whenCreate() => when(
        () => userArticles.createArticle(
          draft: any(named: 'draft'),
          authorId: any(named: 'authorId'),
          authorName: any(named: 'authorName'),
          thumbnail: any(named: 'thumbnail'),
        ),
      );

  group('validation', () {
    test('rejects an invalid draft before touching any repository', () async {
      final result = await useCase(
        PublishArticleParams(draft: buildDraft(title: '')),
      );

      expect(result.failureOrNull?.type, FailureType.validation);
      expect(result.failureOrNull?.message, ArticleValidationError.emptyTitle.message);
      verifyZeroInteractions(userArticles);
      verifyZeroInteractions(storage);
    });

    test('rejects an invalid image before uploading', () async {
      final result = await useCase(
        PublishArticleParams(draft: draft, thumbnail: buildImage(mimeType: 'image/gif')),
      );

      expect(result.failureOrNull?.type, FailureType.validation);
      expect(result.failureOrNull?.message, ImageValidationError.unsupportedType.message);
      verifyZeroInteractions(storage);
    });
  });

  test('fails with unauthenticated when nobody is signed in', () async {
    when(() => auth.currentUser).thenReturn(null);

    final result = await useCase(PublishArticleParams(draft: draft));

    expect(result.failureOrNull?.type, FailureType.unauthenticated);
    verifyZeroInteractions(userArticles);
  });

  test('creates the article without a thumbnail, signed by the current user', () async {
    whenCreate().thenAnswer((_) async => DataSuccess(created));

    final result = await useCase(PublishArticleParams(draft: draft));

    expect(result.dataOrNull, created);
    verify(
      () => userArticles.createArticle(
        draft: draft,
        authorId: user.id,
        authorName: user.preferredName,
        thumbnail: null,
      ),
    ).called(1);
    verifyZeroInteractions(storage);
  });

  test('uploads the thumbnail first and passes its reference to the document', () async {
    when(() => storage.upload(image))
        .thenAnswer((_) async => const DataSuccess(thumbnailReference));
    whenCreate().thenAnswer((_) async => DataSuccess(created));

    final result = await useCase(PublishArticleParams(draft: draft, thumbnail: image));

    expect(result.isSuccess, isTrue);
    verifyInOrder([
      () => storage.upload(image),
      () => userArticles.createArticle(
            draft: draft,
            authorId: user.id,
            authorName: user.preferredName,
            thumbnail: thumbnailReference,
          ),
    ]);
    verifyNever(() => storage.delete(any()));
  });

  test('stops when the upload fails and never creates the document', () async {
    when(() => storage.upload(image))
        .thenAnswer((_) async => const DataFailed(Failure.permissionDenied()));

    final result = await useCase(PublishArticleParams(draft: draft, thumbnail: image));

    expect(result.failureOrNull?.type, FailureType.permissionDenied);
    verifyZeroInteractions(userArticles);
  });

  test('deletes the uploaded thumbnail when the document cannot be created', () async {
    when(() => storage.upload(image))
        .thenAnswer((_) async => const DataSuccess(thumbnailReference));
    when(() => storage.delete(thumbnailReference.path))
        .thenAnswer((_) async => const DataSuccess(null));
    whenCreate().thenAnswer((_) async => const DataFailed(Failure.server()));

    final result = await useCase(PublishArticleParams(draft: draft, thumbnail: image));

    expect(result.failureOrNull?.type, FailureType.server);
    verify(() => storage.delete(thumbnailReference.path)).called(1);
  });
}
