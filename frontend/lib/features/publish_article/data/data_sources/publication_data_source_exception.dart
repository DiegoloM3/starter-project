enum PublicationDataSource {
  firestore,
  storage,
}

enum PublicationDataSourceOperation {
  createArticle,
  getArticle,
  listArticles,
  uploadThumbnail,
  getThumbnailDownloadUrl,
}

class PublicationDataSourceException implements Exception {
  final PublicationDataSource source;
  final PublicationDataSourceOperation operation;
  final String code;
  final String message;
  final Object? cause;

  const PublicationDataSourceException({
    required this.source,
    required this.operation,
    required this.code,
    required this.message,
    this.cause,
  });

  @override
  String toString() {
    return 'PublicationDataSourceException('
        'source: $source, '
        'operation: $operation, '
        'code: $code, '
        'message: $message'
        ')';
  }
}
