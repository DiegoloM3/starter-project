import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

// Pins spec 003 acceptance criteria for the cubit-level orchestration:
// - the feed reflects the repository stream (Scenario 6)
// - publish + uploadImage delegate correctly (Scenario 1)
// - the cubit emits Error when the repository stream errors (Scenario 4
//   surface — error path)

class _FakeRepository implements CommunityArticleRepository {
  final StreamController<List<ArticleEntity>> _controller =
      StreamController<List<ArticleEntity>>.broadcast();

  Object? publishError;
  Object? uploadError;
  Object? deleteError;
  String publishReturnId = 'doc-1';
  String uploadReturnUrl = 'https://example.com/uploaded.jpg';

  ArticleEntity? lastPublished;
  String? lastUploadUid;
  String? lastDeletedFirestoreId;
  String? lastDeletedImageUrl;

  void emit(List<ArticleEntity> articles) => _controller.add(articles);
  void emitError(Object error) => _controller.addError(error);
  Future<void> dispose() => _controller.close();

  @override
  Stream<List<ArticleEntity>> watchArticles() => _controller.stream;

  @override
  Future<String> publishArticle(ArticleEntity article) async {
    if (publishError != null) throw publishError!;
    lastPublished = article;
    return publishReturnId;
  }

  @override
  Future<String> uploadArticleImage({
    required String uid,
    required File imageFile,
  }) async {
    if (uploadError != null) throw uploadError!;
    lastUploadUid = uid;
    return uploadReturnUrl;
  }

  @override
  Future<void> deleteArticle({
    required String firestoreId,
    String? imageUrl,
  }) async {
    if (deleteError != null) throw deleteError!;
    lastDeletedFirestoreId = firestoreId;
    lastDeletedImageUrl = imageUrl;
  }
}

void main() {
  late _FakeRepository repository;
  late CommunityFeedCubit cubit;

  setUp(() {
    repository = _FakeRepository();
    cubit = CommunityFeedCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  group('CommunityFeedCubit', () {
    test('initial state is Loading', () {
      expect(cubit.state, isA<CommunityFeedLoading>());
    });

    test('start() emits Loaded with whatever the repository emits', () async {
      const articles = [
        ArticleEntity(firestoreId: 'a', uid: 'u', title: 'first'),
        ArticleEntity(firestoreId: 'b', uid: 'u', title: 'second'),
      ];

      cubit.start();
      // Wait one microtask for the listener to wire up.
      await Future<void>.delayed(Duration.zero);
      repository.emit(articles);
      await Future<void>.delayed(Duration.zero);

      final state = cubit.state;
      expect(state, isA<CommunityFeedLoaded>());
      expect((state as CommunityFeedLoaded).articles, articles);
    });

    test('start() emits Error when the repository stream errors', () async {
      cubit.start();
      await Future<void>.delayed(Duration.zero);
      repository.emitError(Exception('boom'));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<CommunityFeedError>());
    });

    test('publish forwards the entity to the repository', () async {
      const article = ArticleEntity(uid: 'user-1', title: 't');

      final id = await cubit.publish(article);

      expect(id, 'doc-1');
      expect(repository.lastPublished, article);
    });

    test('publish rethrows when the repository fails', () async {
      repository.publishError = Exception('network');
      const article = ArticleEntity(uid: 'user-1', title: 't');

      expect(() => cubit.publish(article), throwsException);
    });

    test('uploadImage forwards uid and returns the download URL', () async {
      final url = await cubit.uploadImage(
        uid: 'user-7',
        imageFile: File('/tmp/x.jpg'),
      );

      expect(url, 'https://example.com/uploaded.jpg');
      expect(repository.lastUploadUid, 'user-7');
    });

    test('uploadImage rethrows when the repository fails', () async {
      repository.uploadError = Exception('storage down');

      expect(
        () => cubit.uploadImage(uid: 'u', imageFile: File('/tmp/x.jpg')),
        throwsException,
      );
    });

    test('deleteArticle forwards firestoreId and imageUrl', () async {
      await cubit.deleteArticle(
        firestoreId: 'doc-1',
        imageUrl: 'https://example.com/img.jpg',
      );

      expect(repository.lastDeletedFirestoreId, 'doc-1');
      expect(repository.lastDeletedImageUrl, 'https://example.com/img.jpg');
    });

    test('deleteArticle accepts a null imageUrl', () async {
      await cubit.deleteArticle(firestoreId: 'doc-2');

      expect(repository.lastDeletedFirestoreId, 'doc-2');
      expect(repository.lastDeletedImageUrl, isNull);
    });

    test('deleteArticle rethrows when the repository fails', () async {
      repository.deleteError = Exception('permission denied');

      expect(
        () => cubit.deleteArticle(firestoreId: 'doc-1'),
        throwsException,
      );
    });
  });
}
