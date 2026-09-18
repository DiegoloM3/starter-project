import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/article_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/article_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/firebase_article_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/firebase_article_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/firebase_published_articles_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/published_articles_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/publication_data_source_exception.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/repository/publish_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/repository/read_published_articles_repository_impl.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/repository/publish_article_repository.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/repository/read_published_articles_repository.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/get_published_articles_use_case.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/publish_article_use_case.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

import 'features/publish_article/support/publication_data_source_fakes.dart';

// Any unexpected SDK call fails through Fake.noSuchMethod; no Firebase app exists.
class UnusedFirestore extends Fake implements FirebaseFirestore {}

class UnusedStorage extends Fake implements FirebaseStorage {}

void main() {
  late GetIt container;
  setUp(() {
    container = GetIt.asNewInstance();
    registerPublicationDependencies(container);
  });
  tearDown(() => container.reset());

  test(
      'registers Firebase and concrete adapters without eagerly performing I/O',
      () async {
    expect(container.isRegistered<FirebaseFirestore>(), isTrue);
    expect(container.isRegistered<FirebaseStorage>(), isTrue);
    await container.unregister<FirebaseFirestore>();
    await container.unregister<FirebaseStorage>();
    container.registerSingleton<FirebaseFirestore>(UnusedFirestore());
    container.registerSingleton<FirebaseStorage>(UnusedStorage());
    expect(container<ArticleFirestoreDataSource>(),
        isA<FirebaseArticleFirestoreDataSource>());
    expect(container<ArticleStorageDataSource>(),
        isA<FirebaseArticleStorageDataSource>());
    expect(container<PublishedArticlesFirestoreDataSource>(),
        isA<FirebasePublishedArticlesFirestoreDataSource>());
    expect(container<PublishArticleRepository>(),
        isA<PublishArticleRepositoryImpl>());
    expect(container<PublishArticleRepository>(),
        same(container<PublishArticleRepository>()));
    expect(container<PublishArticleUseCase>(),
        same(container<PublishArticleUseCase>()));
    expect(container<ReadPublishedArticlesRepository>(),
        isA<ReadPublishedArticlesRepositoryImpl>());
    expect(container<GetPublishedArticlesUseCase>(),
        same(container<GetPublishedArticlesUseCase>()));
  });

  test('use case and real repository compose with fake I/O and retain retries',
      () async {
    final events = <String>[];
    final firestore = PublicationFirestoreFake(events);
    final storage = PublicationStorageFake(events);
    await container.unregister<ArticleFirestoreDataSource>();
    await container.unregister<ArticleStorageDataSource>();
    container.registerSingleton<ArticleFirestoreDataSource>(firestore);
    container.registerSingleton<ArticleStorageDataSource>(storage);
    final useCase = container<PublishArticleUseCase>();
    final error = dataError(PublicationDataSource.firestore,
        PublicationDataSourceOperation.createArticle, 'unavailable');
    firestore.createError = error;
    await expectLater(useCase(params: publicationInput(title: '  Title  ')),
        throwsA(same(error)));
    firestore.createError = null;
    final result = await container<PublishArticleUseCase>()(
        params: publicationInput(title: '  Title  '));
    expect(result.article!.id, 'article-1');
    expect(result.article!.title, 'Title');
    expect(firestore.ids, 1);
    expect(events.where((e) => e.startsWith('upload:')), hasLength(1));
  });

  test('domain validation still prevents all datasource operations', () async {
    final events = <String>[];
    await container.unregister<ArticleFirestoreDataSource>();
    await container.unregister<ArticleStorageDataSource>();
    container.registerSingleton<ArticleFirestoreDataSource>(
        PublicationFirestoreFake(events));
    container.registerSingleton<ArticleStorageDataSource>(
        PublicationStorageFake(events));
    final result = await container<PublishArticleUseCase>()(
        params: publicationInput(title: ' '));
    expect(result.errors, isNotEmpty);
    expect(events, isEmpty);
  });

  test('production contains no transitional publishing mock', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in files) {
      expect(file.readAsStringSync(),
          isNot(contains('MockPublishArticleRepository')),
          reason: file.path);
      expect(file.readAsStringSync(),
          isNot(contains('mock-publish-article.invalid')),
          reason: file.path);
    }
    expect(
        File('lib/features/publish_article/data/repository/mock_publish_article_repository.dart')
            .existsSync(),
        isFalse);
  });
}
