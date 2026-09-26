class ArticleImageEntity {
  final List<int> bytes;
  final String fileName;
  final String mimeType;

  const ArticleImageEntity({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  int get sizeInBytes => bytes.length;

  /// Detects the supported raster signature rather than trusting a filename or MIME label.
  String? get detectedMimeType {
    if (_startsWith(<int>[0xFF, 0xD8, 0xFF])) return 'image/jpeg';
    if (_startsWith(<int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'image/webp';
    }
    return null;
  }

  bool get isSupportedRaster => detectedMimeType == mimeType;

  bool _startsWith(List<int> signature) {
    if (bytes.length < signature.length) return false;
    for (var i = 0; i < signature.length; i++) {
      if (bytes[i] != signature[i]) return false;
    }
    return true;
  }
}
