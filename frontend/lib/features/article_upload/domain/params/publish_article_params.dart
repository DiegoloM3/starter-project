import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_location.dart';

class PublishArticleParams extends Equatable {
  final String title;
  final String description;
  final String content;
  final Uint8List imageBytes;
  final String userId;
  final String userDisplayName;
  final String? userPhotoUrl;
  final ArticleCategory category;
  final List<String> tags;
  final String language;
  final ArticleLocation? location;
  final int? draftId;

  const PublishArticleParams({
    required this.title,
    required this.description,
    required this.content,
    required this.imageBytes,
    required this.userId,
    required this.userDisplayName,
    this.userPhotoUrl,
    required this.category,
    required this.tags,
    required this.language,
    this.location,
    this.draftId,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        content,
        imageBytes,
        userId,
        userDisplayName,
        userPhotoUrl,
        category,
        tags,
        language,
        location,
        draftId,
      ];
}
