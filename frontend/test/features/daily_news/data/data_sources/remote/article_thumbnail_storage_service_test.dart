import 'dart:io';

import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_thumbnail_storage_service.dart';

void main() {
  late MockFirebaseStorage storage;
  late ArticleThumbnailStorageService service;

  setUp(() {
    storage = MockFirebaseStorage();
    service = ArticleThumbnailStorageService(storage);
  });

  Future<String> createLocalImage(String fileName) async {
    final image = File('${Directory.systemTemp.path}/$fileName');
    await image.writeAsBytes([0xff, 0xd8, 0xff, 0xe0]);
    return image.path;
  }

  group('ArticleThumbnailStorageService', () {
    test('uploads the thumbnail to media/articles named after the article', () async {
      final localImagePath = await createLocalImage('thumbnail_test.jpg');

      final thumbnailPath = await service.uploadThumbnail('article1', localImagePath);

      expect(thumbnailPath, 'media/articles/article1.jpg');
      expect(storage.storedFilesMap.keys.single, endsWith('media/articles/article1.jpg'));
      expect(storage.storedSettableMetadataMap.values.single['contentType'], 'image/jpeg');
    });

    test('keeps the extension and sets the content type of png images', () async {
      final localImagePath = await createLocalImage('thumbnail_test.PNG');

      final thumbnailPath = await service.uploadThumbnail('article1', localImagePath);

      expect(thumbnailPath, 'media/articles/article1.png');
      expect(storage.storedSettableMetadataMap.values.single['contentType'], 'image/png');
    });

    test('rejects images in a format the storage rules do not accept', () async {
      final localImagePath = await createLocalImage('thumbnail_test.gif');

      expect(
        () => service.uploadThumbnail('article1', localImagePath),
        throwsA(isA<UnsupportedImageFormatException>()),
      );
    });

    test('returns the download URL of a thumbnail', () async {
      final downloadUrl = await service.getDownloadUrl('media/articles/article1.jpg');

      expect(downloadUrl, contains('media/articles/article1.jpg'));
    });
  });
}
