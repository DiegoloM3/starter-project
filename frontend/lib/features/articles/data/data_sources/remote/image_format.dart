import 'dart:typed_data';

/// Format of an image to upload. Cloud Storage only accepts files with an `image/*` content type.
enum ImageFormat {
  jpeg('image/jpeg', 'jpg'),
  png('image/png', 'png'),
  gif('image/gif', 'gif'),
  webp('image/webp', 'webp');

  final String contentType;
  final String extension;

  const ImageFormat(this.contentType, this.extension);

  /// Detects the format from the first bytes of the file. Images picked from the gallery are
  /// compressed to JPEG, so it is the default.
  static ImageFormat of(Uint8List bytes) {
    if (_startsWith(bytes, const [0x89, 0x50, 0x4E, 0x47])) return png;
    if (_startsWith(bytes, const [0x47, 0x49, 0x46])) return gif;
    if (_startsWith(bytes, const [0x52, 0x49, 0x46, 0x46]) && _hasAt(bytes, 8, const [0x57, 0x45, 0x42, 0x50])) {
      return webp;
    }
    return jpeg;
  }

  static bool _startsWith(Uint8List bytes, List<int> signature) => _hasAt(bytes, 0, signature);

  static bool _hasAt(Uint8List bytes, int offset, List<int> signature) {
    if (bytes.length < offset + signature.length) return false;
    for (var index = 0; index < signature.length; index++) {
      if (bytes[offset + index] != signature[index]) return false;
    }
    return true;
  }
}
