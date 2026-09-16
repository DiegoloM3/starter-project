import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_firestore_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/user_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/user_article_repository_impl.dart';

import '../../../../helpers/fixtures.dart';

class MockArticleFirestoreService extends Mock implements ArticleFirestoreService {}

void main() {
  late MockArticleFirestoreService service;
  late UserArticleRepositoryImpl repository;

  UserArticleModel model(String id, {String title = 'Title', DateTime? publishedAt}) =>
      UserArticleModel.fromDraft(
        id: id,
        draft: buildDraft(title: title, publishedAt: publishedAt),
        authorId: 'uid-1',
        authorName: 'Ada',
      );

  setUp(() {
    service = MockArticleFirestoreService();
    repository = UserArticleRepositoryImpl(service);
  });

  test('getArticles maps models to entities, newest first', () async {
    when(() => service.fetchArticles()).thenAnswer((_) async => [
          model('old', publishedAt: DateTime.utc(2026, 1, 1)),
          model('new', publishedAt: DateTime.utc(2026, 9, 1)),
        ]);

    final result = await repository.getArticles();

    expect(result.dataOrNull!.map((a) => a.id), ['new', 'old']);
  });

  test('getArticlesByAuthor sorts on the device', () async {
    when(() => service.fetchArticlesByAuthor('uid-1')).thenAnswer((_) async => [
          model('a', publishedAt: DateTime.utc(2026, 1, 1)),
          model('b', publishedAt: DateTime.utc(2026, 2, 1)),
        ]);

    final result = await repository.getArticlesByAuthor('uid-1');

    expect(result.dataOrNull!.first.id, 'b');
  });

  test('getArticle reports a missing document as notFound', () async {
    when(() => service.fetchArticle('x')).thenAnswer((_) async => null);

    final result = await repository.getArticle('x');

    expect(result.failureOrNull?.type, FailureType.notFound);
  });

  test('searchArticles filters the fetched window case-insensitively', () async {
    when(() => service.fetchArticles(limit: UserArticleRepositoryImpl.searchWindow))
        .thenAnswer((_) async => [model('a', title: 'Tram strike'), model('b', title: 'Weather')]);

    final result = await repository.searchArticles('TRAM');

    expect(result.dataOrNull!.map((a) => a.id), ['a']);
    expect((await repository.searchArticles('  ')).dataOrNull, isEmpty);
  });

  test('createArticle sends the schema map and returns the entity with the new id', () async {
    when(() => service.createArticle(any())).thenAnswer((_) async => 'generated');

    final result = await repository.createArticle(
      draft: buildDraft(),
      authorId: 'uid-1',
      authorName: 'Ada',
      thumbnail: thumbnailReference,
    );

    final sent = verify(() => service.createArticle(captureAny())).captured.single as Map<String, dynamic>;
    expect(sent['authorId'], 'uid-1');
    expect(sent['thumbnailPath'], thumbnailReference.path);
    expect(result.dataOrNull?.id, 'generated');
    expect(result.dataOrNull?.imageUrl, thumbnailReference.url);
  });

  test('updateArticle keeps the stored author and writes the new fields', () async {
    when(() => service.fetchArticle('doc')).thenAnswer((_) async => model('doc'));
    when(() => service.updateArticle('doc', any())).thenAnswer((_) async {});

    final result = await repository.updateArticle(id: 'doc', draft: buildDraft(title: 'Edited'));

    final sent = verify(() => service.updateArticle('doc', captureAny())).captured.single as Map<String, dynamic>;
    expect(sent['title'], 'Edited');
    expect(sent['authorId'], 'uid-1');
    expect(sent['thumbnailURL'], isNull);
    expect(result.dataOrNull?.title, 'Edited');
  });

  test('Firestore errors become domain failures', () async {
    when(() => service.deleteArticle('doc'))
        .thenThrow(FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'));

    final result = await repository.deleteArticle('doc');

    expect(result.failureOrNull?.type, FailureType.permissionDenied);
  });
}
