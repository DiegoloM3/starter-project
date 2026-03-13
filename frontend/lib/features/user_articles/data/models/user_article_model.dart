import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article.dart';

/// Data model for UserArticle that extends the domain entity.
/// Handles serialization/deserialization for Firestore.
class UserArticleModel extends UserArticleEntity {
  const UserArticleModel({
    super.id,
    super.authorId,
    super.authorName,
    super.title,
    super.description,
    super.content,
    super.thumbnailUrl,
    super.sourceUrl,
    super.categories,
    super.isDraft = true,
    super.publishedAt,
    super.createdAt,
    super.updatedAt,
  });

  /// Creates a UserArticleModel from a Firestore document.
  factory UserArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserArticleModel(
      id: doc.id,
      authorId: data['authorId'] as String?,
      authorName: data['authorName'] as String?,
      title: data['title'] as String?,
      description: data['description'] as String?,
      content: data['content'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      sourceUrl: data['sourceUrl'] as String?,
      categories: (data['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isDraft: data['isDraft'] as bool? ?? true,
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Creates a UserArticleModel from a JSON map.
  factory UserArticleModel.fromJson(Map<String, dynamic> json) {
    return UserArticleModel(
      id: json['id'] as String?,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      content: json['content'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isDraft: json['isDraft'] as bool? ?? true,
      publishedAt: json['publishedAt'] != null
          ? (json['publishedAt'] is Timestamp
              ? (json['publishedAt'] as Timestamp).toDate()
              : DateTime.parse(json['publishedAt'] as String))
          : null,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(json['createdAt'] as String))
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['updatedAt'] as String))
          : null,
    );
  }

  /// Creates a UserArticleModel from a domain entity.
  factory UserArticleModel.fromEntity(UserArticleEntity entity) {
    return UserArticleModel(
      id: entity.id,
      authorId: entity.authorId,
      authorName: entity.authorName,
      title: entity.title,
      description: entity.description,
      content: entity.content,
      thumbnailUrl: entity.thumbnailUrl,
      sourceUrl: entity.sourceUrl,
      categories: entity.categories,
      isDraft: entity.isDraft,
      publishedAt: entity.publishedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts the model to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'description': description,
      'content': content,
      'thumbnailUrl': thumbnailUrl,
      'sourceUrl': sourceUrl,
      'categories': categories,
      'isDraft': isDraft,
      'publishedAt':
          publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Converts the model to a JSON map for creating a new document.
  /// Excludes the id field as Firestore will generate it.
  Map<String, dynamic> toCreateJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Creates a copy with updated fields.
  @override
  UserArticleModel copyWith({
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
    return UserArticleModel(
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
}
