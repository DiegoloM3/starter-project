import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/article_storage_service.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/article_thumbnail_repository_impl.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

import '../../../../helpers/article_fixtures.dart';

/// Stand in for the one class that talks to Cloud Storage.
class _FakeArticleStorageService implements ArticleStorageService {
  Object? errorToThrow;
  String downloadUrl = 'https://storage/media/articles/journalist-1/cover.jpg';

  String? lastUserId;
  ArticleThumbnailEntity? lastThumbnail;

  @override
  Future<String> uploadThumbnail({
    required String userId,
    required ArticleThumbnailEntity thumbnail,
  }) async {
    final error = errorToThrow;

    if (error != null) {
      throw error;
    }

    lastUserId = userId;
    lastThumbnail = thumbnail;

    return downloadUrl;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        '${invocation.memberName} is not faked',
      );
}

void main() {
  late _FakeArticleStorageService storage;
  late ArticleThumbnailRepositoryImpl repository;

  setUp(() {
    storage = _FakeArticleStorageService();
    repository = ArticleThumbnailRepositoryImpl(storage);
  });

  test('returns the download url the editor needs to store', () async {
    final result = await repository.uploadThumbnail(
      userId: 'journalist-1',
      thumbnail: thumbnail(),
    );

    expect(result, isA<DataSuccess>());
    expect(result.data, storage.downloadUrl);
    // The upload has to land in the folder the storage rules give this user.
    expect(storage.lastUserId, 'journalist-1');
  });

  test('reports a storage error rather than throwing', () async {
    storage.errorToThrow =
        FirebaseException(plugin: 'firebase_storage', code: 'unauthorized');

    final result = await repository.uploadThumbnail(
      userId: 'journalist-1',
      thumbnail: thumbnail(),
    );

    expect(result, isA<DataFailed>());
    expect(result.error, isA<FirebaseException>());
  });

  /// Without the broad catch this would hang the editor's upload spinner
  /// instead of reporting anything.
  test('reports an unexpected error rather than throwing', () async {
    storage.errorToThrow = StateError('the network stack gave up');

    final result = await repository.uploadThumbnail(
      userId: 'journalist-1',
      thumbnail: thumbnail(),
    );

    expect(result, isA<DataFailed>());
    expect(result.error, isA<StateError>());
  });
}
