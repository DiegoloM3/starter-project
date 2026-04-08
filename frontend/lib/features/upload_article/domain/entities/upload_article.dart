import 'package:equatable/equatable.dart';

class UploadArticleEntity extends Equatable {
  final String author;
  final String title;
  final String description;
  final String content;
  final String url;
  final String urlToImage;

  const UploadArticleEntity({
    required this.author,
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.urlToImage,
  });

  @override
  List<Object?> get props => [author, title, description, content, url, urlToImage];
}
