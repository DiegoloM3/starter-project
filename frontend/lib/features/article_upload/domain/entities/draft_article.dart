import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_location.dart';

class DraftArticleEntity extends Equatable {
  final int id;
  final String title;
  final String description;
  final String content;
  final String? localImagePath;
  final ArticleCategory? category;
  final List<String> tags;
  final String language;
  final ArticleLocation? location;
  final DateTime lastSavedAt;

  const DraftArticleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    this.localImagePath,
    this.category,
    required this.tags,
    required this.language,
    this.location,
    required this.lastSavedAt,
  });

  DraftArticleEntity copyWith({
    int? id,
    String? title,
    String? description,
    String? content,
    String? localImagePath,
    ArticleCategory? category,
    List<String>? tags,
    String? language,
    ArticleLocation? location,
    DateTime? lastSavedAt,
  }) {
    return DraftArticleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      localImagePath: localImagePath ?? this.localImagePath,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      language: language ?? this.language,
      location: location ?? this.location,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        localImagePath,
        category,
        tags,
        language,
        location,
        lastSavedAt,
      ];
}
