class ArticleThumbnail {
  final String fileName;
  final String mimeType;
  final List<int> bytes;

  ArticleThumbnail({
    required this.fileName,
    required this.mimeType,
    required List<int> bytes,
  }) : bytes = List<int>.unmodifiable(bytes);
}
