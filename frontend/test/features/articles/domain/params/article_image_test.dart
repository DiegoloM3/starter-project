import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_draft.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_image.dart';

void main() {
  group('ArticleImage.validationErrors', () {
    test('is empty for an image within the size limit', () {
      final image = ArticleImage(Uint8List(ArticleLimits.imageMaxBytes - 1));

      expect(image.validationErrors, isEmpty);
    });

    test('reports an empty image', () {
      expect(ArticleImage(Uint8List(0)).validationErrors, {ArticleValidationError.imageEmpty});
    });

    test('reports an image of the maximum size or larger', () {
      final image = ArticleImage(Uint8List(ArticleLimits.imageMaxBytes));

      expect(image.validationErrors, {ArticleValidationError.imageTooLarge});
    });
  });
}
