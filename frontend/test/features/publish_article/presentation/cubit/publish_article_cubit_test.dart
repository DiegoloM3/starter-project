import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/publishable_article.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/publish_article_result.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/publish_article_use_case.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/cubit/publish_article_cubit.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/cubit/publish_article_state.dart';

import '../../support/fake_publish_article_repository.dart';
import '../../support/publication_data_source_fakes.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/repository/publish_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/publication_data_source_exception.dart';

class ControlledPublishArticleUseCase extends PublishArticleUseCase {
  final Future<PublishArticleResult> Function(PublishArticleParams params)
      handler;

  ControlledPublishArticleUseCase(this.handler)
      : super(FakePublishArticleRepository());

  @override
  Future<PublishArticleResult> call({PublishArticleParams? params}) {
    if (params == null) {
      throw ArgumentError.notNull('params');
    }

    return handler(params);
  }
}

ArticleThumbnail validThumbnail() {
  return ArticleThumbnail(
    fileName: 'thumbnail.jpg',
    mimeType: 'image/jpeg',
    bytes: const [1, 2, 3],
  );
}

PublishableArticle publishedArticle() {
  final instant = DateTime.utc(2026, 9, 18, 12);

  return PublishableArticle(
    id: 'article-123',
    author: 'Jane Doe',
    title: 'Article title',
    description: 'Article summary',
    content: 'Article content',
    thumbnailUrl: 'https://example.com/thumbnail.jpg',
    publishedAt: instant,
    createdAt: instant,
    updatedAt: instant,
  );
}

void completeValidForm(PublishArticleCubit cubit) {
  cubit.authorChanged('Jane Doe');
  cubit.titleChanged('Article title');
  cubit.descriptionChanged('Article summary');
  cubit.contentChanged('Article content');
  cubit.thumbnailSelected(validThumbnail());
}

void main() {
  test(
      'real repository timeout exits submitting; checking confirms the same ID',
      () async {
    final events = <String>[];
    final firestore = PublicationFirestoreFake(events)
      ..createGate = Completer<void>();
    final repository = PublishArticleRepositoryImpl(
        firestore, PublicationStorageFake(events),
        confirmationWait: const Duration(milliseconds: 10));
    final cubit = PublishArticleCubit(PublishArticleUseCase(repository));
    addTearDown(cubit.close);
    completeValidForm(cubit);
    final transitions = expectLater(
        cubit.stream.map((state) => state.status),
        emitsInOrder([
          PublishArticleStatus.submitting,
          PublishArticleStatus.confirmationPending
        ]));
    await cubit.publish();
    await transitions;
    expect(cubit.state.isSubmitting, isFalse);
    expect(cubit.state.pendingArticleId, 'article-1');
    expect(cubit.state.failureMessage, isNull);
    expect(cubit.state.publishedArticle, isNull);
    expect(cubit.state.validationErrors, isEmpty);
    final pending = cubit.state;
    cubit.authorChanged('Other');
    cubit.titleChanged('Other');
    cubit.descriptionChanged('Other');
    cubit.contentChanged('Other');
    cubit.thumbnailRemoved();
    cubit.thumbnailSelected(validThumbnail());
    expect(cubit.state, same(pending));
    await cubit.publish();
    expect(cubit.state.isConfirmationPending, isTrue);
    firestore.createGate!.complete();
    await cubit.publish();
    expect(cubit.state.isSuccess, isTrue);
    expect(cubit.state.pendingArticleId, isNull);
    expect(cubit.state.publishedArticle!.id, 'article-1');
    expect(firestore.ids, 1);
    expect(events.where((e) => e.startsWith('create:')), hasLength(1));
  });

  test('reopened form checks the retained attempt by ID, not its new fields',
      () async {
    final events = <String>[];
    final firestore = PublicationFirestoreFake(events)
      ..createGate = Completer<void>();
    final useCase = PublishArticleUseCase(PublishArticleRepositoryImpl(
        firestore, PublicationStorageFake(events),
        confirmationWait: const Duration(milliseconds: 10)));
    final first = PublishArticleCubit(useCase);
    completeValidForm(first);
    await first.publish();
    await first.close();
    final reopened = PublishArticleCubit(useCase);
    addTearDown(reopened.close);
    completeValidForm(reopened);
    reopened.titleChanged('A different form');
    await reopened.publish();
    expect(reopened.state.pendingArticleId, 'article-1');
    firestore.createGate!.complete();
    await reopened.publish();
    expect(reopened.state.publishedArticle!.title, 'Article title');
    expect(firestore.ids, 1);
    expect(events.where((e) => e.startsWith('create:')), hasLength(1));
  });

  test('delayed definite rejection exits pending and unlocks editing',
      () async {
    final events = <String>[];
    final firestore = PublicationFirestoreFake(events)
      ..createGate = Completer<void>();
    final cubit = PublishArticleCubit(PublishArticleUseCase(
        PublishArticleRepositoryImpl(firestore, PublicationStorageFake(events),
            confirmationWait: const Duration(milliseconds: 10))));
    addTearDown(cubit.close);
    completeValidForm(cubit);
    await cubit.publish();
    firestore.createGate!.completeError(dataError(
        PublicationDataSource.firestore,
        PublicationDataSourceOperation.createArticle,
        'permission-denied'));
    await cubit.publish();
    expect(cubit.state.status, PublishArticleStatus.failure);
    expect(cubit.state.pendingArticleId, isNull);
    expect(cubit.state.failureMessage, isNotNull);
    expect(cubit.state.isFormLocked, isFalse);
    cubit.titleChanged('Corrected title');
    expect(cubit.state.title, 'Corrected title');
  });

  test('pending publication ignores every edit and keeps original parameters',
      () async {
    final gate = Completer<PublishArticleResult>();
    final calls = <PublishArticleParams>[];
    final cubit = PublishArticleCubit(ControlledPublishArticleUseCase((params) {
      calls.add(params);
      return gate.future;
    }));
    addTearDown(cubit.close);
    completeValidForm(cubit);
    final original = cubit.state;
    final operation = cubit.publish();
    final pending = cubit.state;
    cubit.authorChanged('Other author');
    cubit.titleChanged('Other title');
    cubit.descriptionChanged('Other description');
    cubit.contentChanged('Other content');
    cubit.thumbnailSelected(validThumbnail());
    cubit.thumbnailRemoved();
    await cubit.publish();
    expect(cubit.state, same(pending));
    expect(calls, hasLength(1));
    expect(calls.single.author, original.author);
    expect(calls.single.title, original.title);
    expect(calls.single.description, original.description);
    expect(calls.single.content, original.content);
    expect(calls.single.thumbnail, same(original.thumbnail));
    gate.complete(PublishArticleResult.success(publishedArticle()));
    await operation;
    expect(cubit.state.isSuccess, isTrue);
    expect(calls, hasLength(1));
  });

  test('failure unlocks editing and retry with new parameters', () async {
    final gate = Completer<PublishArticleResult>();
    final calls = <PublishArticleParams>[];
    final cubit = PublishArticleCubit(ControlledPublishArticleUseCase((params) {
      calls.add(params);
      return calls.length == 1
          ? gate.future
          : Future.value(PublishArticleResult.success(publishedArticle()));
    }));
    addTearDown(cubit.close);
    completeValidForm(cubit);
    final operation = cubit.publish();
    gate.completeError(StateError('Controlled failure'));
    await operation;
    expect(cubit.state.status, PublishArticleStatus.failure);
    cubit.authorChanged('New author');
    cubit.titleChanged('New title');
    cubit.descriptionChanged('New description');
    cubit.contentChanged('New content');
    cubit.thumbnailRemoved();
    expect(cubit.state.thumbnail, isNull);
    final replacement = validThumbnail();
    cubit.thumbnailSelected(replacement);
    await cubit.publish();
    expect(calls, hasLength(2));
    expect(calls.last.author, 'New author');
    expect(calls.last.title, 'New title');
    expect(calls.last.description, 'New description');
    expect(calls.last.content, 'New content');
    expect(calls.last.thumbnail, same(replacement));
    expect(cubit.state.isSuccess, isTrue);
  });

  group('PublishArticleCubit', () {
    test('starts with an empty initial state', () async {
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()));

      expect(cubit.state, PublishArticleState());

      await cubit.close();
    });

    test('updates each text field independently', () async {
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()));

      cubit.authorChanged('Jane Doe');
      expect(cubit.state.author, 'Jane Doe');
      expect(cubit.state.title, isEmpty);

      cubit.titleChanged('Article title');
      expect(cubit.state.title, 'Article title');

      cubit.descriptionChanged('Article summary');
      expect(cubit.state.description, 'Article summary');

      cubit.contentChanged('Article content');
      expect(cubit.state.content, 'Article content');

      await cubit.close();
    });

    test('selects and removes a thumbnail', () async {
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()));
      final thumbnail = validThumbnail();

      cubit.thumbnailSelected(thumbnail);
      expect(cubit.state.thumbnail, same(thumbnail));

      cubit.thumbnailRemoved();
      expect(cubit.state.thumbnail, isNull);

      await cubit.close();
    });

    test('emits submitting and success for valid input', () async {
      final article = publishedArticle();
      PublishArticleParams? receivedParams;
      final useCase = ControlledPublishArticleUseCase((params) async {
        receivedParams = params;
        return PublishArticleResult.success(article);
      });
      final cubit = PublishArticleCubit(useCase);

      completeValidForm(cubit);

      final expectation = expectLater(
        cubit.stream.map((state) => state.status),
        emitsInOrder([
          PublishArticleStatus.submitting,
          PublishArticleStatus.success,
        ]),
      );

      await cubit.publish();
      await expectation;

      expect(cubit.state.publishedArticle, same(article));
      expect(cubit.state.validationErrors, isEmpty);
      expect(cubit.state.failureMessage, isNull);
      expect(receivedParams, isNotNull);
      expect(receivedParams!.author, 'Jane Doe');
      expect(receivedParams!.title, 'Article title');
      expect(receivedParams!.description, 'Article summary');
      expect(receivedParams!.content, 'Article content');
      expect(receivedParams!.thumbnail.fileName, 'thumbnail.jpg');

      await cubit.close();
    });

    test('exposes every domain validation error for empty input', () async {
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()));

      final expectation = expectLater(
        cubit.stream.map((state) => state.status),
        emitsInOrder([
          PublishArticleStatus.submitting,
          PublishArticleStatus.validationFailure,
        ]),
      );

      await cubit.publish();
      await expectation;

      expect(
        cubit.state.validationErrors.map((error) => error.field),
        PublishArticleField.values,
      );
      expect(cubit.state.publishedArticle, isNull);
      expect(cubit.state.failureMessage, isNull);

      await cubit.close();
    });

    test('editing a field clears only its validation error', () async {
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()));

      await cubit.publish();
      expect(cubit.state.validationErrors, hasLength(7));

      cubit.authorChanged('Jane Doe');

      expect(cubit.state.status, PublishArticleStatus.initial);
      expect(
        cubit.state.errorFor(PublishArticleField.author),
        isNull,
      );
      expect(cubit.state.validationErrors, hasLength(6));
      expect(
        cubit.state.errorFor(PublishArticleField.title),
        'Required.',
      );

      await cubit.close();
    });

    test('selecting a thumbnail clears all thumbnail validation errors',
        () async {
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()));

      await cubit.publish();
      cubit.thumbnailSelected(validThumbnail());

      expect(cubit.state.thumbnailError, isNull);
      expect(
        cubit.state.validationErrors.map((error) => error.field),
        [
          PublishArticleField.author,
          PublishArticleField.title,
          PublishArticleField.description,
          PublishArticleField.content,
        ],
      );

      await cubit.close();
    });

    test('emits failure when the use case throws unexpectedly', () async {
      final useCase = ControlledPublishArticleUseCase(
        (_) => Future<PublishArticleResult>.error(
          StateError('Unexpected failure'),
        ),
      );
      final cubit = PublishArticleCubit(useCase);

      completeValidForm(cubit);

      final expectation = expectLater(
        cubit.stream.map((state) => state.status),
        emitsInOrder([
          PublishArticleStatus.submitting,
          PublishArticleStatus.failure,
        ]),
      );

      await cubit.publish();
      await expectation;

      expect(
        cubit.state.failureMessage,
        'Unable to publish the article. Please try again.',
      );
      expect(cubit.state.publishedArticle, isNull);

      await cubit.close();
    });

    test('ignores a second publish while a request is in progress', () async {
      final completer = Completer<PublishArticleResult>();
      var calls = 0;
      final useCase = ControlledPublishArticleUseCase((_) {
        calls++;
        return completer.future;
      });
      final cubit = PublishArticleCubit(useCase);

      completeValidForm(cubit);

      final firstPublish = cubit.publish();
      final secondPublish = cubit.publish();

      expect(calls, 1);
      expect(cubit.state.status, PublishArticleStatus.submitting);

      completer.complete(
        PublishArticleResult.success(publishedArticle()),
      );

      await Future.wait([firstPublish, secondPublish]);

      expect(calls, 1);
      expect(cubit.state.status, PublishArticleStatus.success);

      await cubit.close();
    });
  });
}
