import 'dart:io';

class UploadUserArticleParams {
  final String title;
  final String content;
  final File image;

  const UploadUserArticleParams({
    required this.title,
    required this.content,
    required this.image,
  });
}
