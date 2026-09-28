import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';

/// Firestore model for comments. JSON is mapped by hand (no codegen) so
/// this feature needs no build_runner output beyond DI registration.
class CommentModel extends CommentEntity {
  const CommentModel({
    super.id,
    required super.articleId,
    required super.authorId,
    super.authorDisplayName,
    required super.content,
    required super.createdAt,
  }) : super();

  /// Builds a model from a Firestore JSON map.
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String?,
      articleId: json['articleId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorDisplayName: json['authorDisplayName'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleId': articleId,
      'authorId': authorId,
      'authorDisplayName': authorDisplayName,
      'content': content,
      'createdAt': createdAt,
    };
  }

  /// Builds a model from a domain [entity].
  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      articleId: entity.articleId,
      authorId: entity.authorId,
      authorDisplayName: entity.authorDisplayName,
      content: entity.content,
      createdAt: entity.createdAt,
    );
  }

  /// Builds a model from external raw data.
  factory CommentModel.fromRawData(Map<String, dynamic> raw) =>
      CommentModel.fromJson(raw);

  /// Converts this model to its domain [CommentEntity].
  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      articleId: articleId,
      authorId: authorId,
      authorDisplayName: authorDisplayName,
      content: content,
      createdAt: createdAt,
    );
  }

  CommentModel copyWith({
    String? id,
    String? articleId,
    String? authorId,
    String? authorDisplayName,
    String? content,
    String? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
