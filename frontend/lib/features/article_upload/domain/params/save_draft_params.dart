import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_location.dart';

class SaveDraftParams extends Equatable {
  final int? id;
  final String title;
  final String description;
  final String content;
  final String? localImagePath;
  final ArticleCategory? category;
  final List<String> tags;
  final String language;
  final ArticleLocation? location;

  const SaveDraftParams({
    this.id,
    required this.title,
    required this.description,
    required this.content,
    this.localImagePath,
    this.category,
    required this.tags,
    required this.language,
    this.location,
  });

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
      ];
}
