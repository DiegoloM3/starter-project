import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable {
  final int? id;
  final String? author;
  final String? authorId;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  const ArticleEntity({
    this.id,
    this.author,
    this.authorId,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  String get heroTag => 'article_image_${urlToImage ?? id ?? title}';

  @override
  List<Object?> get props {
    return [
      id,
      author,
      authorId,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content,
    ];
  }
}
