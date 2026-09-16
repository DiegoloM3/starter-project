import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/thumbnail_reference.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockUserArticleRepository userArticles;
  late MockThumbnailStorageRepository storage;
  late MockAuthRepository auth;
  late UpdateArticleUseCase useCase;

  final draft = buildDraft(title: 'Edited title');
  final image = buildImage();
  final existing = buildUserArticle(authorId: user.id);
  final existingThumbnail = ThumbnailReference(
    url: existing.imageUrl!,
    path: existing.imagePath!,
  );
  final updated = existing.copyWith(title: 'Edited title');

  setUpAll(() {
    registerFallbackValue(draft);
    registerFallbackValue(image);
  });

  setUp(() {
    userArticles = MockUserArticleRepository();
    storage = MockThumbnailStorageRepository();
    auth = MockAuthRepository();
    useCase = UpdateArticleUseCase(userArticles, storage, auth);
    when(() => auth.currentUser).thenReturn(user);
    when(() => storage.delete(any())).thenAnswer((_) async => const DataSuccess(null));
  });

  When<Future<DataState<ArticleEntity>>> whenUpdate() => when(
        () => userArticles.updateArticle(
          id: any(named: 'id'),
          draft: any(named: 'draft'),
          thumbnail: any(named: 'thumbnail'),
        ),
      );

  test('rejects an invalid draft before touching any repository', () async {
    final result = await useCase(
      UpdateArticleParams(article: existing, draft: buildDraft(content: '')),
    );

    expect(result.failureOrNull?.type, FailureType.validation);
    verifyZeroInteractions(userArticles);
    verifyZeroInteractions(storage);
  });

  test('fails with unauthenticated when nobody is signed in', () async {
    when(() => auth.currentUser).thenReturn(null);

    final result = await useCase(UpdateArticleParams(article: existing, draft: draft));

    expect(result.failureOrNull?.type, FailureType.unauthenticated);
  });

  test('refuses to edit an article owned by someone else', () async {
    final foreign = buildUserArticle(authorId: 'someone-else');

    final result = await useCase(UpdateArticleParams(article: foreign, draft: draft));

    expect(result.failureOrNull?.type, FailureType.permissionDenied);
    verifyZeroInteractions(userArticles);
  });

  test('keeps the current thumbnail when no image change is requested', () async {
    whenUpdate().thenAnswer((_) async => DataSuccess(updated));

    final result = await useCase(UpdateArticleParams(article: existing, draft: draft));

    expect(result.dataOrNull, updated);
    verify(
      () => userArticles.updateArticle(
        id: existing.id,
        draft: draft,
        thumbnail: existingThumbnail,
      ),
    ).called(1);
    verifyZeroInteractions(storage);
  });

  test('uploads the new image, updates, then deletes the previous file', () async {
    when(() => storage.upload(image))
        .thenAnswer((_) async => const DataSuccess(thumbnailReference));
    whenUpdate().thenAnswer((_) async => DataSuccess(updated));

    final result = await useCase(
      UpdateArticleParams(article: existing, draft: draft, newThumbnail: image),
    );

    expect(result.isSuccess, isTrue);
    verifyInOrder([
      () => storage.upload(image),
      () => userArticles.updateArticle(
            id: existing.id,
            draft: draft,
            thumbnail: thumbnailReference,
          ),
      () => storage.delete(existingThumbnail.path),
    ]);
  });

  test('deletes the freshly uploaded image when the update fails', () async {
    when(() => storage.upload(image))
        .thenAnswer((_) async => const DataSuccess(thumbnailReference));
    whenUpdate().thenAnswer((_) async => const DataFailed(Failure.server()));

    final result = await useCase(
      UpdateArticleParams(article: existing, draft: draft, newThumbnail: image),
    );

    expect(result.failureOrNull?.type, FailureType.server);
    verify(() => storage.delete(thumbnailReference.path)).called(1);
    verifyNever(() => storage.delete(existingThumbnail.path));
  });

  test('stops when the new image cannot be uploaded', () async {
    when(() => storage.upload(image))
        .thenAnswer((_) async => const DataFailed(Failure.network()));

    final result = await useCase(
      UpdateArticleParams(article: existing, draft: draft, newThumbnail: image),
    );

    expect(result.failureOrNull?.type, FailureType.network);
    verifyZeroInteractions(userArticles);
  });

  test('removes the thumbnail: updates without image, then deletes the old file', () async {
    whenUpdate().thenAnswer((_) async => DataSuccess(updated.copyWith()));

    final result = await useCase(
      UpdateArticleParams(article: existing, draft: draft, removeThumbnail: true),
    );

    expect(result.isSuccess, isTrue);
    verify(
      () => userArticles.updateArticle(id: existing.id, draft: draft, thumbnail: null),
    ).called(1);
    verify(() => storage.delete(existingThumbnail.path)).called(1);
  });

  test('removing a thumbnail from an article without one touches no storage', () async {
    final plain = buildUserArticle(authorId: user.id, imageUrl: null, imagePath: null);
    whenUpdate().thenAnswer((_) async => DataSuccess(plain));

    await useCase(UpdateArticleParams(article: plain, draft: draft, removeThumbnail: true));

    verifyZeroInteractions(storage);
  });
}
