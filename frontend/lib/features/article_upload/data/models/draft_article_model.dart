import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_location.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';

@Entity(tableName: 'draft_articles')
class DraftArticleModel extends DraftArticleEntity {
  @PrimaryKey(autoGenerate: true)
  final int? draftId;

  final String? categoryRaw;

  // Floor does not support List<String>; tags are joined with commas.
  // Tags must not contain commas — upstream params validation enforces this.
  final String tagsRaw;

  final double? locationLat;
  final double? locationLng;
  final String? locationPlaceName;

  final int lastSavedAtMillis;

  DraftArticleModel({
    this.draftId,
    required String title,
    required String description,
    required String content,
    String? localImagePath,
    this.categoryRaw,
    required this.tagsRaw,
    required String language,
    this.locationLat,
    this.locationLng,
    this.locationPlaceName,
    required this.lastSavedAtMillis,
  }) : super(
          id: draftId ?? 0,
          title: title,
          description: description,
          content: content,
          localImagePath: localImagePath,
          category: categoryRaw == null
              ? null
              : ArticleCategory.fromApiValue(categoryRaw),
          tags: tagsRaw.isEmpty ? const [] : tagsRaw.split(','),
          language: language,
          location: (locationLat != null && locationLng != null)
              ? ArticleLocation(
                  latitude: locationLat,
                  longitude: locationLng,
                  placeName: locationPlaceName,
                )
              : null,
          lastSavedAt: DateTime.fromMillisecondsSinceEpoch(lastSavedAtMillis),
        );

  factory DraftArticleModel.fromEntity(DraftArticleEntity entity) {
    return DraftArticleModel(
      draftId: entity.id == 0 ? null : entity.id,
      title: entity.title,
      description: entity.description,
      content: entity.content,
      localImagePath: entity.localImagePath,
      categoryRaw: entity.category?.toApiValue(),
      tagsRaw: entity.tags.join(','),
      language: entity.language,
      locationLat: entity.location?.latitude,
      locationLng: entity.location?.longitude,
      locationPlaceName: entity.location?.placeName,
      lastSavedAtMillis: entity.lastSavedAt.millisecondsSinceEpoch,
    );
  }

  DraftArticleEntity toEntity() {
    return DraftArticleEntity(
      id: draftId ?? 0,
      title: title,
      description: description,
      content: content,
      localImagePath: localImagePath,
      category: categoryRaw == null
          ? null
          : ArticleCategory.fromApiValue(categoryRaw!),
      tags: tagsRaw.isEmpty ? const [] : tagsRaw.split(','),
      language: language,
      location: (locationLat != null && locationLng != null)
          ? ArticleLocation(
              latitude: locationLat!,
              longitude: locationLng!,
              placeName: locationPlaceName,
            )
          : null,
      lastSavedAt: DateTime.fromMillisecondsSinceEpoch(lastSavedAtMillis),
    );
  }
}
