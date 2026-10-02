import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

void main() {
  final bytes = Uint8List.fromList([1, 2, 3]);

  group('fromRawData', () {
    test('takes the type of the image from its file name', () {
      expect(ArticleThumbnailModel.fromRawData(bytes, 'photo.png').fileExtension, 'png');
    });

    test('uses lower case, as storage.rules require', () {
      expect(ArticleThumbnailModel.fromRawData(bytes, 'IMG_0001.JPG').fileExtension, 'jpg');
    });

    test('uses the last extension of the file name', () {
      expect(ArticleThumbnailModel.fromRawData(bytes, 'my.holiday.photo.webp').fileExtension, 'webp');
    });

    test('has no extension when the file name has none', () {
      expect(ArticleThumbnailModel.fromRawData(bytes, 'photo').fileExtension, '');
    });
  });

  group('contentType', () {
    final expectedContentTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'gif': 'application/octet-stream',
    };

    expectedContentTypes.forEach((extension, contentType) {
      test('is $contentType for .$extension', () {
        expect(ArticleThumbnailModel(bytes: bytes, fileExtension: extension).contentType, contentType);
      });
    });
  });

  test('converts from and to an entity keeping the image', () {
    final entity = ArticleThumbnailEntity(bytes: bytes, fileExtension: 'PNG');

    final model = ArticleThumbnailModel.fromEntity(entity);

    expect(model.fileExtension, 'png');
    expect(model.toEntity(), ArticleThumbnailEntity(bytes: bytes, fileExtension: 'png'));
  });
}
