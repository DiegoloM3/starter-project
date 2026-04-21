class UpdateArticleParams {
  final String articleId;
  final String title;
  final String description;
  final String content;
  final List<int>? newThumbnailBytes;
  final String? newThumbnailFileName;

  const UpdateArticleParams({
    required this.articleId,
    required this.title,
    required this.description,
    required this.content,
    this.newThumbnailBytes,
    this.newThumbnailFileName,
  });
}
