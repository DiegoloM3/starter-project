import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String? id;
  final String? articleId;
  final String? authorId;
  final String? authorName;
  final String? content;
  final String? createdAt;
  final bool? isDeleted;

  const CommentEntity({
    this.id,
    this.articleId,
    this.authorId,
    this.authorName,
    this.content,
    this.createdAt,
    this.isDeleted,
  });

  @override
  List<Object?> get props => [
    id, articleId, authorId, authorName,
    content, createdAt, isDeleted,
  ];
}
