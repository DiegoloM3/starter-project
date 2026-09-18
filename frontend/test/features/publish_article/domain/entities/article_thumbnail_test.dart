import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/article_thumbnail.dart';

void main() {
  test('copies the original byte list defensively', () {
    final original = [1, 2, 3];
    final thumbnail = ArticleThumbnail(
      fileName: 'image.jpg',
      mimeType: 'image/jpeg',
      bytes: original,
    );
    original[0] = 9;
    original.add(4);
    expect(thumbnail.bytes, [1, 2, 3]);
  });

  test('prevents changing or adding bytes', () {
    final thumbnail = ArticleThumbnail(
      fileName: 'image.jpg',
      mimeType: 'image/jpeg',
      bytes: [1, 2, 3],
    );
    expect(() => thumbnail.bytes[0] = 9, throwsUnsupportedError);
    expect(() => thumbnail.bytes.add(4), throwsUnsupportedError);
  });
}
