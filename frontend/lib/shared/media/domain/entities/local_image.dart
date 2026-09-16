import 'package:equatable/equatable.dart';

/// Constraints for every image the app uploads (article thumbnails and
/// profile photos). They mirror `backend/storage.rules`.
abstract final class ImageLimits {
  static const int maxSizeInBytes = 5 * 1024 * 1024;
  static const Set<String> allowedMimeTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };
}

enum ImageValidationError {
  unsupportedType('Use a JPEG, PNG or WebP image.'),
  tooLarge('The image must be smaller than 5 MB.');

  final String message;

  const ImageValidationError(this.message);
}

/// An image picked on the device, before it is uploaded.
class LocalImage extends Equatable {
  /// Absolute path on the device file system.
  final String path;
  final String mimeType;
  final int sizeInBytes;

  const LocalImage({
    required this.path,
    required this.mimeType,
    required this.sizeInBytes,
  });

  List<ImageValidationError> validate() {
    final errors = <ImageValidationError>[];
    if (!ImageLimits.allowedMimeTypes.contains(mimeType.toLowerCase())) {
      errors.add(ImageValidationError.unsupportedType);
    }
    if (sizeInBytes > ImageLimits.maxSizeInBytes) {
      errors.add(ImageValidationError.tooLarge);
    }
    return errors;
  }

  bool get isValid => validate().isEmpty;

  /// File extension a stored copy should carry, derived from the MIME type.
  String get fileExtension => switch (mimeType.toLowerCase()) {
        'image/png' => 'png',
        'image/webp' => 'webp',
        _ => 'jpg',
      };

  @override
  List<Object?> get props => [path, mimeType, sizeInBytes];
}
