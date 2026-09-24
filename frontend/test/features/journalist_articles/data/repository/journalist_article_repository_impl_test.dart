import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/network_failure.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/journalist_article_model.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/journalist_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';

import '../../../../helpers/article_fixtures.dart';
import '../../../../helpers/fake_firestore_article_service.dart';

/// What this repository owes the layers above it: a [DataState] every time,
/// entities rather than models, and Firestore's vocabulary translated into
/// the domain's own failures.
void main() {
  late FakeFirestoreArticleService service;
  late JournalistArticleRepositoryImpl repository;

  setUp(() {
    service = FakeFirestoreArticleService();
    repository = JournalistArticleRepositoryImpl(service);
  });

  group('getUserArticles', () {
    test('hands back entities, not models', () async {
      service.articles = [
        JournalistArticleModel.fromEntity(publishableArticle()),
      ];

      final result = await repository.getUserArticles(userId: 'journalist-1');

      expect(result, isA<DataSuccess>());
      expect(result.data, hasLength(1));
      expect(result.data!.first.title, publishableArticle().title);
    });

    test('reports a Firestore error instead of letting it escape', () async {
      service.errorToThrow = firestoreError('permission-denied');

      final result = await repository.getUserArticles(userId: 'journalist-1');

      expect(result, isA<DataFailed>());
      // Nothing claimed this was about one article, so the Firestore error
      // is reported as it came rather than guessed at.
      expect(result.error, isA<RemoteException>());
    });
  });

  group('getArticleById', () {
    test('reports a missing document as ArticleNotFoundException', () async {
      service.articleById = null;

      final result = await repository.getArticleById('article-1');

      expect(result, isA<DataFailed>());
      expect(result.error, isA<ArticleNotFoundException>());
    });

    /// The provider's `not-found` and the domain's "no such article" are the
    /// same event with two vocabularies. Only the domain's reaches the bloc.
    test('translates the provider not-found into the domain failure', () async {
      service.errorToThrow = firestoreError('not-found');

      final result = await repository.getArticleById('article-1');

      expect(result.error, isA<ArticleNotFoundException>());
      expect((result.error as ArticleNotFoundException).articleId, 'article-1');
    });

    test('returns the article when it is there', () async {
      service.articleById =
          JournalistArticleModel.fromEntity(publishableArticle());

      final result = await repository.getArticleById('article-1');

      expect(result, isA<DataSuccess>());
      expect(result.data!.title, publishableArticle().title);
    });
  });

  group('createArticle', () {
    test('stamps createdAt and updatedAt on the way down', () async {
      final before = DateTime.now();

      await repository.createArticle(publishableArticle(id: null));

      final written = service.lastWritten!;
      expect(written.createdAt, isNotNull);
      expect(written.updatedAt!.isBefore(before), isFalse);
    });

    /// An article written weeks ago and only now stored keeps the date it was
    /// started on; only `updatedAt` moves.
    test('keeps a createdAt the article already had', () async {
      final started = DateTime(2026, 3, 14, 9, 30);

      await repository.createArticle(
        publishableArticle(id: null).copyWith(createdAt: started),
      );

      expect(service.lastWritten!.createdAt, started);
    });
  });

  group('updateArticle', () {
    test('refuses an article that was never stored', () async {
      final result = await repository.updateArticle(
        publishableArticle(id: null),
      );

      expect(result, isA<DataFailed>());
      expect(result.error, isA<ArticleNotStoredException>());
      // Nothing must have been sent to Firestore.
      expect(service.lastWritten, isNull);
    });

    test('moves updatedAt forward', () async {
      final stale = DateTime(2026, 1, 1);

      await repository.updateArticle(
        publishableArticle().copyWith(updatedAt: stale),
      );

      expect(service.lastWritten!.updatedAt!.isAfter(stale), isTrue);
    });
  });

  group('deleteArticle', () {
    test('deletes the article it was given', () async {
      final result = await repository.deleteArticle('article-1');

      expect(result, isA<DataSuccess>());
      expect(service.lastDeletedId, 'article-1');
    });

    test('reports a deletion it was not allowed to make', () async {
      service.errorToThrow = firestoreError('permission-denied');

      final result = await repository.deleteArticle('article-1');

      expect(result, isA<DataFailed>());
    });
  });

  group('incrementViewCount', () {
    test('counts the reading', () async {
      await repository.incrementViewCount('article-1');

      expect(service.lastViewedId, 'article-1');
    });

    test('reports an article that is no longer there', () async {
      service.errorToThrow = firestoreError('not-found');

      final result = await repository.incrementViewCount('article-1');

      expect(result.error, isA<ArticleNotFoundException>());
    });
  });

  /// The broad catch is the point: an error that escapes a repository does
  /// not surface as a failure, it leaves the caller's `await` hanging and the
  /// screen spinning forever.
  test('an unexpected error still comes back as a failure', () async {
    service.errorToThrow = StateError('something nobody anticipated');

    final result = await repository.getUserArticles(userId: 'journalist-1');

    expect(result, isA<DataFailed>());
    expect(result.error, isA<StateError>());
  });

  /// The one provider failure the journalist can do something about.
  ///
  /// Publishing in airplane mode used to report "Something went wrong", which
  /// names nothing to try — while the one thing that would have helped was
  /// finding signal. The data source now gives up on a call that goes past
  /// its deadline and raises Firestore's own `unavailable`; this is where
  /// that stops being a provider code and becomes something the app can say.
  group('a backend that could not be reached', () {
    for (final code in [
      'unavailable',
      'deadline-exceeded',
      'network-request-failed'
    ]) {
      test('$code is reported as no connection', () async {
        service.errorToThrow = firestoreError(code);

        final result = await repository.createArticle(publishableArticle());

        expect(result, isA<DataFailed>());
        expect(result.error, isA<NetworkUnavailableException>());
      });
    }

    test('on an operation that names one article too', () async {
      service.errorToThrow = firestoreError('unavailable');

      final result = await repository.deleteArticle('article-1');

      // `not-found` is the only code an articleId changes the reading of; a
      // connection failure is a connection failure either way.
      expect(result.error, isA<NetworkUnavailableException>());
    });

    test('a document that is not there is still reported as not found',
        () async {
      service.errorToThrow = firestoreError('not-found');

      final result = await repository.deleteArticle('article-1');

      expect(result.error, isA<ArticleNotFoundException>());
    });

    test('any other provider code is passed up as it came', () async {
      service.errorToThrow = firestoreError('permission-denied');

      final result = await repository.createArticle(publishableArticle());

      expect(result.error, isA<RemoteException>());
      expect((result.error as RemoteException).code, 'permission-denied');
    });
  });

  group('updateAuthorName', () {
    test('passes the rename down and answers how many it reached', () async {
      service.renamedCount = 4;

      final result = await repository.updateAuthorName(
        userId: 'journalist-1',
        authorName: 'Alex Rivera',
      );

      expect(result, isA<DataSuccess<int>>());
      expect(result.data, 4);
      expect(service.lastRenamedUserId, 'journalist-1');
      expect(service.lastAuthorName, 'Alex Rivera');
    });

    test('reports a failure instead of letting it escape', () async {
      service.errorToThrow = firestoreError('permission-denied');

      final result = await repository.updateAuthorName(
        userId: 'journalist-1',
        authorName: 'Alex Rivera',
      );

      expect(result, isA<DataFailed<int>>());
    });
  });
}
