class CreateArticleParams {
  final String title;
  final String description;
  final String content;
  final String author;
  final String authorId;
  final String thumbnailPath;

  const CreateArticleParams({
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.authorId,
    required this.thumbnailPath,
  });
}
