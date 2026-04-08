import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/community_articles/data/data_sources/remote/community_article_remote_datasource.dart';
import 'package:news_app_clean_architecture/features/community_articles/data/repository/community_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

// Pins spec 003 data layer: the repository is a thin pass-through to the
// remote data source. The interesting logic (Firestore mapping, Storage path
// composition) lives in CommunityArticleFirestoreDataSource which requires
// the real Firebase emulator and is exercised by the manual end-to-end run.

class _FakeRemoteDataSource implements CommunityArticleRemoteDataSource {
  final List<ArticleEntity> emitted;
  final String? uploadReturnUrl;
  final String? publishReturnId;
  Object? uploadError;
  Object? publishError;
  Object? deleteError;

  String? lastUploadUid;
  File? lastUploadFile;
  ArticleEntity? lastPublishArticle;
  String? lastDeletedFirestoreId;
  String? lastDeletedImageUrl;
  int deleteCallCount = 0;

  _FakeRemoteDataSource({
    this.emitted = const [],
    this.uploadReturnUrl,
    this.publishReturnId,
  });

  @override
  Stream<List<ArticleEntity>> watchArticles() => Stream.value(emitted);

  @override
  Future<String> uploadArticleImage({
    required String uid,
    required File imageFile,
  }) async {
    if (uploadError != null) throw uploadError!;
    lastUploadUid = uid;
    lastUploadFile = imageFile;
    return uploadReturnUrl ?? 'https://example.com/uploaded.jpg';
  }

  @override
  Future<String> publishArticle(ArticleEntity article) async {
    if (publishError != null) throw publishError!;
    lastPublishArticle = article;
    return publishReturnId ?? 'doc-123';
  }

  @override
  Future<void> deleteArticle({
    required String firestoreId,
    String? imageUrl,
  }) async {
    deleteCallCount++;
    if (deleteError != null) throw deleteError!;
    lastDeletedFirestoreId = firestoreId;
    lastDeletedImageUrl = imageUrl;
  }
}

void main() {
  group('CommunityArticleRepositoryImpl', () {
    test('watchArticles forwards the remote stream', () async {
      const article = ArticleEntity(
        firestoreId: 'doc-1',
        uid: 'u',
        title: 't',
      );
      final remote = _FakeRemoteDataSource(emitted: [article]);
      final repo = CommunityArticleRepositoryImpl(remote);

      final result = await repo.watchArticles().first;

      expect(result, [article]);
    });

    test('uploadArticleImage forwards uid and file', () async {
      final remote = _FakeRemoteDataSource(uploadReturnUrl: 'https://x/y.jpg');
      final repo = CommunityArticleRepositoryImpl(remote);
      final tempFile = File('/tmp/fake.jpg');

      final url = await repo.uploadArticleImage(
        uid: 'user-1',
        imageFile: tempFile,
      );

      expect(url, 'https://x/y.jpg');
      expect(remote.lastUploadUid, 'user-1');
      expect(remote.lastUploadFile?.path, '/tmp/fake.jpg');
    });

    test('publishArticle forwards the entity and returns the doc id', () async {
      final remote = _FakeRemoteDataSource(publishReturnId: 'doc-xyz');
      final repo = CommunityArticleRepositoryImpl(remote);
      const article = ArticleEntity(uid: 'u', title: 't');

      final id = await repo.publishArticle(article);

      expect(id, 'doc-xyz');
      expect(remote.lastPublishArticle, article);
    });

    test('deleteArticle forwards both firestoreId and imageUrl', () async {
      final remote = _FakeRemoteDataSource();
      final repo = CommunityArticleRepositoryImpl(remote);

      await repo.deleteArticle(
        firestoreId: 'doc-1',
        imageUrl: 'https://x/y.jpg',
      );

      expect(remote.deleteCallCount, 1);
      expect(remote.lastDeletedFirestoreId, 'doc-1');
      expect(remote.lastDeletedImageUrl, 'https://x/y.jpg');
    });

    test('deleteArticle accepts a null imageUrl', () async {
      final remote = _FakeRemoteDataSource();
      final repo = CommunityArticleRepositoryImpl(remote);

      await repo.deleteArticle(firestoreId: 'doc-1');

      expect(remote.deleteCallCount, 1);
      expect(remote.lastDeletedFirestoreId, 'doc-1');
      expect(remote.lastDeletedImageUrl, isNull);
    });
  });
}
