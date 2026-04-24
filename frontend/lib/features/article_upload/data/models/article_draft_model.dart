import 'dart:convert';
import '../../domain/entities/article_draft_entity.dart';

class ArticleDraftModel extends ArticleDraftEntity {
  const ArticleDraftModel({
    required super.title,
    required super.content,
    required super.tags,
    super.thumbnailLocalPath,
    required super.updatedAt,
  });

  factory ArticleDraftModel.fromJson(Map<String, dynamic> json) {
    return ArticleDraftModel(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      tags: List<String>.from(json['tags'] as List? ?? []),
      thumbnailLocalPath: json['thumbnailLocalPath'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'tags': tags,
        'thumbnailLocalPath': thumbnailLocalPath,
        'updatedAt': updatedAt.toIso8601String(),
      };

  String toJsonString() => jsonEncode(toJson());

  static ArticleDraftModel fromJsonString(String source) =>
      ArticleDraftModel.fromJson(jsonDecode(source) as Map<String, dynamic>);

  static ArticleDraftModel fromEntity(ArticleDraftEntity entity) =>
      ArticleDraftModel(
        title: entity.title,
        content: entity.content,
        tags: entity.tags,
        thumbnailLocalPath: entity.thumbnailLocalPath,
        updatedAt: entity.updatedAt,
      );
}
