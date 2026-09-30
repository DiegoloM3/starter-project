import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

ArticleThumbnailEntity thumbnailAt(String localPath, {int sizeInBytes = 1024}) {
  return ArticleThumbnailEntity(localPath: localPath, sizeInBytes: sizeInBytes);
}

void main() {
  group('extension', () {
    test('is the lowercase file extension', () {
      expect(thumbnailAt('/gallery/IMG_001.PNG').extension, 'png');
      expect(thumbnailAt('/gallery/photo.webp').extension, 'webp');
    });

    test('normalizes jpeg to jpg, the name used in Cloud Storage', () {
      expect(thumbnailAt('/gallery/photo.jpeg').extension, 'jpg');
      expect(thumbnailAt('/gallery/photo.JPG').extension, 'jpg');
    });

    test('is empty when the file has no extension', () {
      expect(thumbnailAt('/gallery/photo').extension, '');
    });

    test('ignores dots in folder names', () {
      expect(thumbnailAt('/data/com.example.app/cache/photo').extension, '');
    });
  });

  group('isSupportedFormat', () {
    for (final path in ['/a.jpg', '/a.jpeg', '/a.png', '/a.webp']) {
      test('accepts $path', () {
        expect(thumbnailAt(path).isSupportedFormat, isTrue);
      });
    }

    for (final path in ['/a.heic', '/a.gif', '/a.bmp', '/a']) {
      test('rejects $path', () {
        expect(thumbnailAt(path).isSupportedFormat, isFalse);
      });
    }
  });

  group('exceedsMaxSize', () {
    test('accepts exactly 5 MB', () {
      final thumbnail = thumbnailAt('/a.jpg', sizeInBytes: ArticleThumbnailEntity.maxSizeInBytes);

      expect(thumbnail.exceedsMaxSize, isFalse);
    });

    test('rejects one byte over 5 MB', () {
      final thumbnail = thumbnailAt('/a.jpg', sizeInBytes: ArticleThumbnailEntity.maxSizeInBytes + 1);

      expect(thumbnail.exceedsMaxSize, isTrue);
    });

    test('max size is 5 MB, matching storage.rules', () {
      expect(ArticleThumbnailEntity.maxSizeInBytes, 5 * 1024 * 1024);
    });
  });
}
