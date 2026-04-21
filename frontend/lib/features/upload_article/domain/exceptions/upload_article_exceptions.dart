sealed class UploadArticleException implements Exception {
  final String message;
  const UploadArticleException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class UnauthenticatedException extends UploadArticleException {
  const UnauthenticatedException()
      : super('You must be signed in to upload an article.');
}

class InvalidArticleException extends UploadArticleException {
  const InvalidArticleException(super.message);
}

class UploadFailedException extends UploadArticleException {
  const UploadFailedException(super.message);
}
