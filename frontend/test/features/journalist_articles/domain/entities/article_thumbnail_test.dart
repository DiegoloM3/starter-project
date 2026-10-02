import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

ArticleThumbnailEntity buildThumbnail({int sizeInBytes = 1024, String fileExtension = 'png'}) {
  return ArticleThumbnailEntity(bytes: Uint8List(sizeInBytes), fileExtension: fileExtension);
}

void main() {
  group('hasAllowedExtension', () {
    for (final extension in ['jpg', 'jpeg', 'png', 'webp', 'PNG']) {
      test('accepts .$extension', () {
        expect(buildThumbnail(fileExtension: extension).hasAllowedExtension, isTrue);
      });
    }

    for (final extension in ['gif', 'svg', 'pdf', '']) {
      test('rejects "$extension"', () {
        expect(buildThumbnail(fileExtension: extension).hasAllowedExtension, isFalse);
      });
    }
  });

  group('isWithinMaxSize', () {
    test('accepts an image of exactly 5 MB', () {
      final thumbnail = buildThumbnail(sizeInBytes: ArticleThumbnailEntity.maxSizeInBytes);
      expect(thumbnail.isWithinMaxSize, isTrue);
    });

    test('rejects an image bigger than 5 MB', () {
      final thumbnail = buildThumbnail(sizeInBytes: ArticleThumbnailEntity.maxSizeInBytes + 1);
      expect(thumbnail.isWithinMaxSize, isFalse);
    });
  });
}
