import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('LocalImage.validate', () {
    for (final type in ['image/jpeg', 'image/png', 'image/webp', 'IMAGE/PNG']) {
      test('accepts $type', () {
        expect(buildImage(mimeType: type).isValid, isTrue);
      });
    }

    test('rejects unsupported types', () {
      expect(buildImage(mimeType: 'image/gif').validate(),
          [ImageValidationError.unsupportedType]);
      expect(buildImage(mimeType: 'application/pdf').validate(),
          [ImageValidationError.unsupportedType]);
    });

    test('accepts exactly the maximum size', () {
      expect(buildImage(sizeInBytes: ImageLimits.maxSizeInBytes).isValid, isTrue);
    });

    test('rejects an image over the maximum size', () {
      expect(buildImage(sizeInBytes: ImageLimits.maxSizeInBytes + 1).validate(),
          [ImageValidationError.tooLarge]);
    });

    test('reports both problems together', () {
      final image = buildImage(mimeType: 'image/gif', sizeInBytes: 10 * 1024 * 1024);
      expect(image.validate(), [
        ImageValidationError.unsupportedType,
        ImageValidationError.tooLarge,
      ]);
    });

  });
}
