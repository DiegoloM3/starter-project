import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/image_format.dart';

void main() {
  Uint8List bytesOf(List<int> header) => Uint8List.fromList([...header, 0, 0, 0, 0, 0, 0, 0, 0]);

  test('detects PNG images', () {
    expect(ImageFormat.of(bytesOf([0x89, 0x50, 0x4E, 0x47])), ImageFormat.png);
  });

  test('detects GIF images', () {
    expect(ImageFormat.of(bytesOf([0x47, 0x49, 0x46, 0x38])), ImageFormat.gif);
  });

  test('detects WebP images', () {
    final header = [0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x45, 0x42, 0x50];

    expect(ImageFormat.of(bytesOf(header)), ImageFormat.webp);
  });

  test('treats anything else as JPEG, the format of the compressed gallery images', () {
    expect(ImageFormat.of(bytesOf([0xFF, 0xD8, 0xFF])), ImageFormat.jpeg);
  });

  test('knows the content type and extension of each format', () {
    expect(ImageFormat.png.contentType, 'image/png');
    expect(ImageFormat.jpeg.extension, 'jpg');
  });
}
