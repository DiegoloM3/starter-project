/// Limits shared with the Firestore security rules.
class CommentLimits {
  static const int textMaxLength = 500;
}

enum CommentValidationError { textEmpty, textTooLong }

class AddCommentParams {
  final String articleId;
  final String text;

  AddCommentParams({required this.articleId, required String text}) : text = text.trim();

  Set<CommentValidationError> get validationErrors => {
    if (text.isEmpty) CommentValidationError.textEmpty,
    if (text.length > CommentLimits.textMaxLength) CommentValidationError.textTooLong,
  };
}
