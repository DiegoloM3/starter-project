sealed class CommentException implements Exception {
  final String message;
  const CommentException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class InvalidCommentException extends CommentException {
  const InvalidCommentException(super.message);
}

class CommentFailedException extends CommentException {
  const CommentFailedException(super.message);
}
