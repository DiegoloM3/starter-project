sealed class ArticleException implements Exception {
  final String message;
  const ArticleException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class ArticleFetchException extends ArticleException {
  const ArticleFetchException(super.message);
}
