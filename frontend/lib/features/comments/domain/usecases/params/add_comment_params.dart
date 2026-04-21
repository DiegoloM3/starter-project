class AddCommentParams {
  final String articleId;
  final String text;
  final String? replyTo;

  const AddCommentParams({
    required this.articleId,
    required this.text,
    this.replyTo,
  });
}
