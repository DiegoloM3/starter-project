import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';

class ArticleEntity extends Equatable {
  final int? id;
  final String? documentId;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
  final NewsSection? section;
  final List<String> images;
  final String? userId;

  const ArticleEntity({
    this.id,
    this.documentId,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.section,
    this.images = const [],
    this.userId,
  });

  @override
  List<Object?> get props {
    return [
      id,
      documentId,
      author,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content,
      section,
      images,
      userId,
    ];
  }
}
