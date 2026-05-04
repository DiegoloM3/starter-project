import 'dart:typed_data';

import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/remote/article_storage_service_impl.dart';

void main() {
  late MockFirebaseStorage mockStorage;
  late ArticleStorageServiceImpl service;

  setUp(() {
    mockStorage = MockFirebaseStorage();
    service = ArticleStorageServiceImpl(mockStorage);
  });

  group('uploadThumbnail', () {
    test('happy path returns a non-empty download URL', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final url = await service.uploadThumbnail(
        articleId: 'article-001',
        bytes: bytes,
        contentType: 'image/jpeg',
      );
      expect(url, isA<String>());
      expect(url, isNotEmpty);
    });

    test('uploads to the correct path', () async {
      final bytes = Uint8List.fromList([10, 20, 30]);
      await service.uploadThumbnail(
        articleId: 'article-xyz',
        bytes: bytes,
        contentType: 'image/jpeg',
      );

      final ref = mockStorage
          .ref()
          .child('media/articles/article-xyz/thumbnail.jpg');
      // Verify the data was stored at the expected path by checking the ref data.
      final storedData = await ref.getData();
      expect(storedData, isNotNull);
    });
  });

  group('deleteThumbnail', () {
    test('deletes the file at the correct path', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      await service.uploadThumbnail(
        articleId: 'article-del',
        bytes: bytes,
        contentType: 'image/jpeg',
      );

      // Delete should not throw.
      await expectLater(
        service.deleteThumbnail('article-del'),
        completes,
      );
    });
  });

  group('exception mapping', () {
    test('StorageException has the correct localizedMessage', () {
      const ex = StorageException(
        message: 'bucket not found',
        code: 'object-not-found',
      );
      expect(ex.localizedMessage, contains('storage'));
      expect(ex.code, equals('object-not-found'));
    });
  });
}
