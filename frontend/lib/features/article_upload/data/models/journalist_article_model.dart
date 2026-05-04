import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_location.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';

class JournalistArticleModel extends JournalistArticleEntity {
  const JournalistArticleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.content,
    required super.urlToImage,
    required super.publishedAt,
    required super.userId,
    required super.userDisplayName,
    super.userPhotoUrl,
    required super.source,
    required super.category,
    required super.tags,
    required super.language,
    required super.readingTimeMinutes,
    super.location,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.viewCount,
    required super.favoriteCount,
    super.isDeleted = false,
    super.deletedAt,
  });

  factory JournalistArticleModel.fromRawData(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return JournalistArticleModel(
      id: snapshot.id,
      title: data['title'] as String,
      description: data['description'] as String,
      content: data['content'] as String,
      urlToImage: data['urlToImage'] as String,
      // Server timestamps may be null briefly while the local cache holds a
      // pending write before the server confirms. Fall back to local clock —
      // the next emission will overwrite with the real value.
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] as String,
      userDisplayName: data['userDisplayName'] as String,
      userPhotoUrl: data['userPhotoUrl'] as String?,
      source: data['source'] as String? ?? 'journalist',
      category: ArticleCategory.fromApiValue(data['category'] as String),
      tags: ((data['tags'] as List<dynamic>?) ?? const []).cast<String>(),
      language: data['language'] as String? ?? 'en',
      readingTimeMinutes: (data['readingTimeMinutes'] as num?)?.toInt() ?? 1,
      location: data['location'] is Map<String, dynamic>
          ? ArticleLocation(
              latitude:
                  (data['location']['latitude'] as num).toDouble(),
              longitude:
                  (data['location']['longitude'] as num).toDouble(),
              placeName: data['location']['placeName'] as String?,
            )
          : null,
      status: ArticleStatus.fromApiValue(
          data['status'] as String? ?? 'published'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      viewCount: (data['viewCount'] as num?)?.toInt() ?? 0,
      favoriteCount: (data['favoriteCount'] as num?)?.toInt() ?? 0,
      isDeleted: data['isDeleted'] as bool? ?? false,
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Serializes the article for a Firestore write.
  ///
  /// `createdAt`, `updatedAt`, and `publishedAt` are intentionally omitted —
  /// the data source layer sets them via `FieldValue.serverTimestamp()` so
  /// timestamp ordering is canonical and immune to client clock skew.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'urlToImage': urlToImage,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userPhotoUrl': userPhotoUrl,
      'source': source,
      'category': category.toApiValue(),
      'tags': tags,
      'language': language,
      'readingTimeMinutes': readingTimeMinutes,
      'location': location == null
          ? null
          : {
              'latitude': location!.latitude,
              'longitude': location!.longitude,
              'placeName': location!.placeName,
            },
      'status': status.toApiValue(),
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
    };
  }

  JournalistArticleEntity toEntity() => this;
}
