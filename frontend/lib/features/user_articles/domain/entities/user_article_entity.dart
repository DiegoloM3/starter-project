import 'package:equatable/equatable.dart';

class UserArticleEntity extends Equatable {
  final String? id;
  final String title;
  final String content;
  final String thumbnailUrl;
  final DateTime publishedAt;

  const UserArticleEntity({
    this.id,
    required this.title,
    required this.content,
    required this.thumbnailUrl,
    required this.publishedAt,
  });

  @override
  List<Object?> get props => [id, title, content, thumbnailUrl, publishedAt];
}