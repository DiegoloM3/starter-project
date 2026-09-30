import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/image_metadata_remover.dart';

import '../../../../../fixtures/images_with_metadata.dart';

const privateMarkers = ['SecretCam', 'Model X', 'secret-xmp', 'secret comment', 'secret-text'];

void expectNoPrivateMetadata(Uint8List image) {
  final text = latin1.decode(image);
  for (final marker in privateMarkers) {
    expect(text, isNot(contains(marker)), reason: 'still contains "$marker"');
  }
}

List<String> pngChunkTypes(Uint8List png) {
  final types = <String>[];
  var offset = 8;
  while (offset + 8 <= png.length) {
    final length = ByteData.sublistView(png, offset, offset + 4).getUint32(0);
    types.add(latin1.decode(png.sublist(offset + 4, offset + 8)));
    offset += 12 + length;
  }
  return types;
}

void main() {
  group('JPEG', () {
    test('removes EXIF (GPS, camera), XMP and comments', () {
      expectNoPrivateMetadata(ImageMetadataRemover.removeMetadata(jpegRotatedWithMetadata));
    });

    test('keeps the orientation, so rotated photos are not shown sideways', () {
      expect(ImageMetadataRemover.jpegOrientationOf(jpegRotatedWithMetadata), 6);

      final cleaned = ImageMetadataRemover.removeMetadata(jpegRotatedWithMetadata);

      expect(ImageMetadataRemover.jpegOrientationOf(cleaned), 6);
    });

    test('keeps no EXIF at all when the photo is upright', () {
      final cleaned = ImageMetadataRemover.removeMetadata(jpegUprightWithMetadata);

      expect(latin1.decode(cleaned), isNot(contains('Exif')));
      expect(ImageMetadataRemover.jpegOrientationOf(cleaned), isNull);
    });

    test('keeps a valid JPEG: start and end markers and the image data', () {
      final cleaned = ImageMetadataRemover.removeMetadata(jpegRotatedWithMetadata);

      expect(cleaned.sublist(0, 2), [0xFF, 0xD8]);
      expect(cleaned.sublist(cleaned.length - 2), [0xFF, 0xD9]);
      expect(cleaned.length, lessThan(jpegRotatedWithMetadata.length));
      final originalImageData = jpegRotatedWithMetadata.sublist(_startOfScan(jpegRotatedWithMetadata));
      expect(cleaned.sublist(_startOfScan(cleaned)), originalImageData);
    });
  });

  group('PNG', () {
    test('removes eXIf and text chunks and keeps the image chunks in order', () {
      final cleaned = ImageMetadataRemover.removeMetadata(pngWithMetadata);

      expectNoPrivateMetadata(cleaned);
      expect(pngChunkTypes(cleaned), ['IHDR', 'IDAT', 'IEND']);
      expect(cleaned.sublist(0, 8), pngWithMetadata.sublist(0, 8));
    });
  });

  group('WebP', () {
    test('removes the EXIF and XMP chunks and their flags', () {
      final cleaned = ImageMetadataRemover.removeMetadata(webpWithMetadata);

      expectNoPrivateMetadata(cleaned);
      final text = latin1.decode(cleaned);
      expect(text, isNot(contains('EXIF')));
      expect(text, isNot(contains('XMP ')));
    });

    test('keeps a consistent RIFF size', () {
      final cleaned = ImageMetadataRemover.removeMetadata(webpWithMetadata);

      final riffSize = ByteData.sublistView(cleaned, 4, 8).getUint32(0, Endian.little);
      expect(riffSize, cleaned.length - 8);
    });
  });

  test('is idempotent', () {
    final once = ImageMetadataRemover.removeMetadata(jpegRotatedWithMetadata);

    expect(ImageMetadataRemover.removeMetadata(once), once);
  });

  test('leaves other formats untouched (they are rejected before upload anyway)', () {
    final heic = Uint8List.fromList(latin1.encode('....ftypheic....'));

    expect(ImageMetadataRemover.removeMetadata(heic), heic);
  });

  test('rejects a truncated JPEG instead of uploading it with its metadata', () {
    final truncated = jpegRotatedWithMetadata.sublist(0, 30);

    expect(() => ImageMetadataRemover.removeMetadata(truncated), throwsFormatException);
  });
}

int _startOfScan(Uint8List jpeg) {
  for (var index = 2; index < jpeg.length - 1; index++) {
    if (jpeg[index] == 0xFF && jpeg[index + 1] == 0xDA) return index;
  }
  throw StateError('no SOS marker');
}
