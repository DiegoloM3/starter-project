import '../params/add_comment_params.dart';

class CommentValidationException implements Exception {
  final Set<CommentValidationError> errors;

  const CommentValidationException(this.errors);
}
