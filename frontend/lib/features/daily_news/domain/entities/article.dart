import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable {
  final String? id;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? publishedAt;
  final String? content;

  const ArticleEntity({
    this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.publishedAt,
    this.content,
  });

  @override
  List<Object?> get props {
    return [
      id,
      author,
      title,
      description,
      url,
      publishedAt,
      content,
    ];
  }

  ArticleEntity copyWith({
    String? id,
    String? author,
    String? title,
    String? description,
    String? url,
    String? publishedAt,
    String? content,
  }) =>
      ArticleEntity(
        id: id ?? this.id,
        author: author ?? this.author,
        title: title ?? this.title,
        description: description ?? this.description,
        url: url ?? this.url,
        publishedAt: publishedAt ?? this.publishedAt,
        content: content ?? this.content,
      );
}
