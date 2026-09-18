import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/publication_data_source_exception.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/models/publishable_article_model.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/repository/publish_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/publishable_article.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/publication_confirmation_pending.dart';

import '../../support/publication_data_source_fakes.dart';

void main() {
  late List<String> events;
  late PublicationFirestoreFake firestore;
  late PublicationStorageFake storage;
  late PublishArticleRepositoryImpl repository;
  const path = 'media/articles/article-1/thumbnail.jpg';
  final writeError = dataError(PublicationDataSource.firestore,
      PublicationDataSourceOperation.createArticle, 'unavailable');
  final readError = dataError(PublicationDataSource.firestore,
      PublicationDataSourceOperation.getArticle, 'unavailable');
  final uploadError = dataError(PublicationDataSource.storage,
      PublicationDataSourceOperation.uploadThumbnail, 'retry-limit-exceeded');

  setUp(() {
    events = [];
    firestore = PublicationFirestoreFake(events);
    storage = PublicationStorageFake(events);
    repository = PublishArticleRepositoryImpl(firestore, storage);
  });

  group('bounded confirmation of a queued write', () {
    final pending = throwsA(isA<PublicationConfirmationPending>()
        .having((result) => result.articleId, 'article ID', 'article-1'));

    setUp(() {
      firestore.createGate = Completer<void>();
      repository = PublishArticleRepositoryImpl(firestore, storage,
          confirmationWait: const Duration(milliseconds: 10));
    });

    test('timeout and repeated checks retain one native write and storage path',
        () async {
      await expectLater(repository.publishArticle(publicationInput()), pending);
      await expectLater(repository.confirmPublication('article-1'), pending);
      await expectLater(repository.publishArticle(publicationInput()), pending);
      expect(firestore.createGate!.isCompleted, isFalse);
      expect(firestore.ids, 1);
      expect(events.where((e) => e.startsWith('upload:')), ['upload:$path']);
      expect(
          events.where((e) => e.startsWith('create:')), ['create:article-1']);
    });

    test('different input cannot allocate a second article while unresolved',
        () async {
      await expectLater(repository.publishArticle(publicationInput()), pending);
      await expectLater(
          repository.publishArticle(publicationInput(title: 'Changed')),
          pending);
      expect(firestore.ids, 1);
      expect(events.where((e) => e.startsWith('create:')), hasLength(1));
    });

    test('delayed acknowledgment is confirmed on the same attempt', () async {
      await expectLater(repository.publishArticle(publicationInput()), pending);
      final recovery = repository.confirmPublication('article-1');
      firestore.createGate!.complete();
      final article = await recovery;
      expect(article.id, 'article-1');
      expect(article.thumbnailUrl, storage.objects[path]);
      expect(firestore.ids, 1);
      expect(events.where((e) => e.startsWith('create:')), hasLength(1));
      expect(events.where((e) => e.startsWith('upload:')), hasLength(1));
      // Once explicitly confirmed, deliberate later publications remain valid.
      expect((await repository.publishArticle(publicationInput())).id,
          'article-2');
    });

    test(
        'server read can confirm persistence even before native acknowledgment',
        () async {
      final input = publicationInput();
      await expectLater(repository.publishArticle(input), pending);
      firestore.documents['article-1'] = PublishableArticleModel(
        id: 'article-1',
        author: input.author,
        title: input.title,
        description: input.description,
        content: input.content,
        thumbnailUrl: storage.objects[path]!,
        publishedAt: DateTime.utc(2026),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      expect(
          (await repository.confirmPublication('article-1')).id, 'article-1');
      expect(firestore.createGate!.isCompleted, isFalse);
      expect(events.where((e) => e.startsWith('create:')), hasLength(1));
      // A late error on the original future must remain observed after timeout.
      firestore.createGate!.completeError(writeError);
      await Future<void>.delayed(Duration.zero);
    });

    test(
        'unavailable or stalled confirmation stays pending without another write',
        () async {
      await expectLater(repository.publishArticle(publicationInput()), pending);
      firestore.reads.add(readError);
      await expectLater(repository.confirmPublication('article-1'), pending);
      firestore.readGate = Completer<void>();
      await expectLater(repository.confirmPublication('article-1'), pending);
      expect(events.where((e) => e.startsWith('create:')), hasLength(1));
      expect(firestore.ids, 1);
    });

    test('delayed definite rejection preserves failure and same-ID retry',
        () async {
      await expectLater(repository.publishArticle(publicationInput()), pending);
      final denied = dataError(PublicationDataSource.firestore,
          PublicationDataSourceOperation.createArticle, 'permission-denied');
      firestore.createGate!.completeError(denied);
      await expectLater(
          repository.confirmPublication('article-1'), throwsA(same(denied)));
      firestore.createGate = null;
      expect((await repository.publishArticle(publicationInput())).id,
          'article-1');
      expect(firestore.ids, 1);
      expect(events.where((e) => e.startsWith('upload:')), hasLength(1));
    });

    test('concurrent checks still share one foreground operation', () async {
      await expectLater(repository.publishArticle(publicationInput()), pending);
      await Future.wait([
        expectLater(repository.confirmPublication('article-1'), pending),
        expectLater(repository.confirmPublication('article-1'), pending),
      ]);
      expect(events.where((e) => e.startsWith('get:')), hasLength(1));
      expect(events.where((e) => e.startsWith('create:')), hasLength(1));
    });

    test('a stalled reconciliation read does not hide a definite rejection',
        () async {
      final denied = dataError(PublicationDataSource.firestore,
          PublicationDataSourceOperation.createArticle, 'permission-denied');
      firestore
        ..createGate = null
        ..createError = denied
        ..readGate = Completer<void>();
      await expectLater(
          repository.publishArticle(publicationInput()), throwsA(same(denied)));
      firestore
        ..createError = null
        ..readGate = null;
      expect((await repository.publishArticle(publicationInput())).id,
          'article-1');
      expect(firestore.ids, 1);
    });
  });

  for (final entry in {
    'image/jpeg': 'jpg',
    'image/png': 'png',
    'image/webp': 'webp'
  }.entries) {
    test('publishes ${entry.key} with safe path, same ID and exact order',
        () async {
      final input = publicationInput(mime: entry.key);
      final entity = await repository.publishArticle(input);
      expect(events, [
        'id',
        'upload:media/articles/article-1/thumbnail.${entry.value}',
        'create:article-1',
        'get:article-1'
      ]);
      expect(entity.runtimeType, PublishableArticle);
      expect(entity, isNot(isA<PublishableArticleModel>()));
      expect(entity.id, 'article-1');
      expect(entity.author, input.author);
      expect(entity.title, input.title);
      expect(entity.description, input.description);
      expect(entity.content, input.content);
      expect(entity.thumbnailUrl, storage.objects.values.single);
      expect(entity.publishedAt, DateTime.utc(2020));
      expect(entity.createdAt, DateTime.utc(2021));
      expect(entity.updatedAt, DateTime.utc(2022));
      expect(firestore.receivedParams, same(input));
      expect(storage.receivedThumbnail, same(input.thumbnail));
    });
  }

  test('recovers an uncertain upload from the same path', () async {
    storage
      ..uploadError = uploadError
      ..storeBeforeError = true;
    final entity = await repository.publishArticle(publicationInput());
    expect(entity.id, 'article-1');
    expect(events, [
      'id',
      'upload:$path',
      'find:$path',
      'create:article-1',
      'get:article-1'
    ]);
  });
  test('recovers URL retrieval failure after upload', () async {
    storage
      ..uploadError = dataError(PublicationDataSource.storage,
          PublicationDataSourceOperation.getThumbnailDownloadUrl, 'unknown')
      ..storeBeforeError = true;
    await repository.publishArticle(publicationInput());
    expect(events.where((e) => e.startsWith('upload:')), hasLength(1));
    expect(events, contains('find:$path'));
  });
  test('missing image after uncertain upload propagates original error',
      () async {
    storage.uploadError = uploadError;
    await expectLater(repository.publishArticle(publicationInput()),
        throwsA(same(uploadError)));
    expect(events, ['id', 'upload:$path', 'find:$path']);
  });
  test(
      'retry with new equal params reuses ID and finds an already uploaded image',
      () async {
    storage
      ..uploadError = uploadError
      ..storeBeforeError = true
      ..lookupError = readError;
    await expectLater(repository.publishArticle(publicationInput()),
        throwsA(same(readError)));
    storage
      ..uploadError = null
      ..lookupError = null;
    final entity = await repository.publishArticle(publicationInput());
    expect(entity.id, 'article-1');
    expect(firestore.ids, 1);
    expect(events.where((e) => e.startsWith('upload:')), hasLength(1));
  });
  test('retry reuploads a confirmed absent image at the same path', () async {
    storage.uploadError = uploadError;
    await expectLater(repository.publishArticle(publicationInput()),
        throwsA(same(uploadError)));
    storage.uploadError = null;
    await repository.publishArticle(publicationInput());
    expect(firestore.ids, 1);
    expect(events.where((e) => e.startsWith('upload:')),
        ['upload:$path', 'upload:$path']);
  });
  test('reconciles a write which succeeded but returned an error', () async {
    firestore
      ..createError = writeError
      ..storeBeforeError = true;
    final entity = await repository.publishArticle(publicationInput());
    expect(entity.id, 'article-1');
    expect(events, ['id', 'upload:$path', 'create:article-1', 'get:article-1']);
  });
  test('write failure then retry reuses image and ID after confirming absence',
      () async {
    firestore.createError = writeError;
    await expectLater(repository.publishArticle(publicationInput()),
        throwsA(same(writeError)));
    firestore.createError = null;
    await repository.publishArticle(publicationInput());
    expect(events, [
      'id',
      'upload:$path',
      'create:article-1',
      'get:article-1',
      'get:article-1',
      'create:article-1',
      'get:article-1'
    ]);
  });
  test('unresolved write followed by confirmed document never writes twice',
      () async {
    firestore
      ..createError = writeError
      ..storeBeforeError = true;
    firestore.reads.add(readError);
    await expectLater(repository.publishArticle(publicationInput()),
        throwsA(same(writeError)));
    final entity = await repository.publishArticle(publicationInput());
    expect(entity.id, 'article-1');
    expect(firestore.ids, 1);
    expect(events.where((e) => e.startsWith('create:')), hasLength(1));
  });
  test('a failed confirmation is reconciled by one bounded read', () async {
    firestore.reads.add(readError);
    await repository.publishArticle(publicationInput());
    expect(events, [
      'id',
      'upload:$path',
      'create:article-1',
      'get:article-1',
      'get:article-1'
    ]);
  });
  test('failed confirmation keeps attempt for later read-only retry', () async {
    firestore.reads.addAll([readError, readError]);
    await expectLater(repository.publishArticle(publicationInput()),
        throwsA(same(readError)));
    final entity = await repository.publishArticle(publicationInput());
    expect(entity.id, 'article-1');
    expect(events.where((e) => e.startsWith('upload:')), hasLength(1));
    expect(events.where((e) => e.startsWith('create:')), hasLength(1));
    expect(firestore.ids, 1);
  });
  test('acknowledged write is not repeated even when retry reads not-found',
      () async {
    firestore.reads.addAll([readError, readError]);
    await expectLater(repository.publishArticle(publicationInput()),
        throwsA(same(readError)));
    firestore.documents.clear();
    await expectLater(
        repository.publishArticle(publicationInput()),
        throwsA(isA<PublicationDataSourceException>()
            .having((e) => e.code, 'code', 'not-found')));
    expect(events.where((e) => e.startsWith('create:')), hasLength(1));
    expect(firestore.ids, 1);
  });
  test('unavailable reconciliation on retry never creates another article',
      () async {
    firestore.createError = writeError;
    await expectLater(repository.publishArticle(publicationInput()),
        throwsA(same(writeError)));
    firestore.reads.add(readError);
    await expectLater(repository.publishArticle(publicationInput()),
        throwsA(same(readError)));
    expect(firestore.ids, 1);
    expect(events.where((e) => e.startsWith('create:')), hasLength(1));
  });
  test('definitive upload errors propagate without creating Firestore data',
      () async {
    final error = dataError(PublicationDataSource.storage,
        PublicationDataSourceOperation.uploadThumbnail, 'unauthorized');
    storage.uploadError = error;
    await expectLater(
        repository.publishArticle(publicationInput()), throwsA(same(error)));
    expect(events, ['id', 'upload:$path']);
  });
  test('definitive create errors propagate after checking the same document',
      () async {
    final error = dataError(PublicationDataSource.firestore,
        PublicationDataSourceOperation.createArticle, 'permission-denied');
    firestore.createError = error;
    await expectLater(
        repository.publishArticle(publicationInput()), throwsA(same(error)));
    expect(events.last, 'get:article-1');
    expect(firestore.ids, 1);
  });
  test('ID allocation failure propagates before uploading', () async {
    firestore.idError = writeError;
    await expectLater(repository.publishArticle(publicationInput()),
        throwsA(same(writeError)));
    expect(events, ['id']);
  });
  test('same input in parallel shares one publication', () async {
    storage.gate = Completer<void>();
    final first = repository.publishArticle(publicationInput());
    final second = repository.publishArticle(publicationInput());
    storage.gate!.complete();
    final entities = await Future.wait([first, second]);
    expect(entities[0].id, entities[1].id);
    expect(events, ['id', 'upload:$path', 'create:article-1', 'get:article-1']);
  });
  test(
      'changed input has its own ID and does not discard an older pending attempt',
      () async {
    firestore.createError = writeError;
    await expectLater(repository.publishArticle(publicationInput()),
        throwsA(same(writeError)));
    firestore.createError = null;
    expect(
        (await repository.publishArticle(publicationInput(bytes: [9, 8, 7])))
            .id,
        'article-2');
    expect(
        (await repository.publishArticle(publicationInput())).id, 'article-1');
    expect(firestore.ids, 2);
  });
  test(
      'confirmed attempts are released so a later deliberate publication gets a new ID',
      () async {
    expect(
        (await repository.publishArticle(publicationInput())).id, 'article-1');
    expect(
        (await repository.publishArticle(publicationInput())).id, 'article-2');
  });
  test('conflicting document is never accepted as a successful publication',
      () async {
    firestore.reads.addAll(List.generate(
        2,
        (_) => PublishableArticleModel(
            id: 'article-1',
            author: 'Someone else',
            title: 'Other title',
            description: 'Other',
            content: 'Other',
            thumbnailUrl: 'other',
            publishedAt: DateTime.utc(2020),
            createdAt: DateTime.utc(2020),
            updatedAt: DateTime.utc(2020))));
    await expectLater(
        repository.publishArticle(publicationInput()),
        throwsA(isA<PublicationDataSourceException>()
            .having((e) => e.code, 'code', 'publication-conflict')));
    expect(firestore.ids, 1);
  });
}
