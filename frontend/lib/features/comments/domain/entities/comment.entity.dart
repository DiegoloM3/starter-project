import 'package:equatable/equatable.dart';

/// Business object for a comment on an article, with content rules.
class CommentEntity extends Equatable {
  final String? id;
  final String articleId;
  final String authorId;
  final String? authorDisplayName;
  final String content;
  final String createdAt;

  static const int maxContentLength = 2000;

  const CommentEntity({
    this.id,
    required this.articleId,
    required this.authorId,
    this.authorDisplayName,
    required this.content,
    required this.createdAt,
  });

  /// Business rule: a comment must carry usable markdown text and stay
  /// within the length budget. Blank or oversized content is rejected
  /// before it ever reaches the data layer.
  bool get hasUsableContent {
    final trimmed = content.trim();
    return trimmed.isNotEmpty && trimmed.length <= maxContentLength;
  }

  @override
  List<Object?> get props {
    return [
      id,
      articleId,
      authorId,
      authorDisplayName,
      content,
      createdAt,
    ];
  }
}
