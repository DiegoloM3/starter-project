import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/delete_article.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockUserArticleRepository userArticles;
  late MockThumbnailStorageRepository storage;
  late MockAuthRepository auth;
  late DeleteArticleUseCase useCase;

  final own = buildUserArticle(authorId: user.id);

  setUp(() {
    userArticles = MockUserArticleRepository();
    storage = MockThumbnailStorageRepository();
    auth = MockAuthRepository();
    useCase = DeleteArticleUseCase(userArticles, storage, auth);
    when(() => auth.currentUser).thenReturn(user);
  });

  test('fails with unauthenticated when nobody is signed in', () async {
    when(() => auth.currentUser).thenReturn(null);

    final result = await useCase(own);

    expect(result.failureOrNull?.type, FailureType.unauthenticated);
    verifyZeroInteractions(userArticles);
  });

  test('refuses to delete an article owned by someone else', () async {
    final result = await useCase(buildUserArticle(authorId: 'other'));

    expect(result.failureOrNull?.type, FailureType.permissionDenied);
    verifyZeroInteractions(userArticles);
    verifyZeroInteractions(storage);
  });

  test('deletes the document and then its thumbnail', () async {
    when(() => userArticles.deleteArticle(own.id))
        .thenAnswer((_) async => const DataSuccess(null));
    when(() => storage.delete(own.imagePath!))
        .thenAnswer((_) async => const DataSuccess(null));

    final result = await useCase(own);

    expect(result.isSuccess, isTrue);
    verifyInOrder([
      () => userArticles.deleteArticle(own.id),
      () => storage.delete(own.imagePath!),
    ]);
  });

  test('skips storage when the article has no thumbnail', () async {
    final plain = buildUserArticle(authorId: user.id, imageUrl: null, imagePath: null);
    when(() => userArticles.deleteArticle(plain.id))
        .thenAnswer((_) async => const DataSuccess(null));

    final result = await useCase(plain);

    expect(result.isSuccess, isTrue);
    verifyZeroInteractions(storage);
  });

  test('propagates the failure and keeps the thumbnail when the document survives', () async {
    when(() => userArticles.deleteArticle(own.id))
        .thenAnswer((_) async => const DataFailed(Failure.network()));

    final result = await useCase(own);

    expect(result.failureOrNull?.type, FailureType.network);
    verifyZeroInteractions(storage);
  });

  test('still succeeds when only the thumbnail deletion fails', () async {
    when(() => userArticles.deleteArticle(own.id))
        .thenAnswer((_) async => const DataSuccess(null));
    when(() => storage.delete(any()))
        .thenAnswer((_) async => const DataFailed(Failure.server()));

    final result = await useCase(own);

    expect(result.isSuccess, isTrue);
  });
}
