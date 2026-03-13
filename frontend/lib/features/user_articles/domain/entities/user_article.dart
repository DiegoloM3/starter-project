import 'package:equatable/equatable.dart';

/// Entity representing a user-created article.
/// This is a pure business object with no dependencies on external frameworks.
class UserArticleEntity extends Equatable {
  final String? id;
  final String? authorId;
  final String? authorName;
  final String? title;
  final String? description;
  final String? content;
  final String? thumbnailUrl;
  final String? sourceUrl;
  final List<String>? categories;
  final bool isDraft;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserArticleEntity({
    this.id,
    this.authorId,
    this.authorName,
    this.title,
    this.description,
    this.content,
    this.thumbnailUrl,
    this.sourceUrl,
    this.categories,
    this.isDraft = true,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this entity with the given fields replaced.
  UserArticleEntity copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? title,
    String? description,
    String? content,
    String? thumbnailUrl,
    String? sourceUrl,
    List<String>? categories,
    bool? isDraft,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserArticleEntity(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      categories: categories ?? this.categories,
      isDraft: isDraft ?? this.isDraft,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        authorName,
        title,
        description,
        content,
        thumbnailUrl,
        sourceUrl,
        categories,
        isDraft,
        publishedAt,
        createdAt,
        updatedAt,
      ];
}
