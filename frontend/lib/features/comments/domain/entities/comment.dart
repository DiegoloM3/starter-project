import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String articleId;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.articleId,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  bool isAuthoredBy(String? userId) => userId != null && userId == authorId;

  @override
  List<Object?> get props => [id, articleId, authorId, authorName, text, createdAt];
}
