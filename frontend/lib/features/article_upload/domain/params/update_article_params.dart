import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_location.dart';

class UpdateArticleParams extends Equatable {
  final String articleId;
  final String title;
  final String description;
  final String content;
  final Uint8List? newImageBytes;
  final ArticleCategory category;
  final List<String> tags;
  final String language;
  final ArticleLocation? location;

  const UpdateArticleParams({
    required this.articleId,
    required this.title,
    required this.description,
    required this.content,
    this.newImageBytes,
    required this.category,
    required this.tags,
    required this.language,
    this.location,
  });

  @override
  List<Object?> get props => [
        articleId,
        title,
        description,
        content,
        newImageBytes,
        category,
        tags,
        language,
        location,
      ];
}
