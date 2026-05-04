import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_location.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_status.dart';

class JournalistArticleEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String content;
  final String urlToImage;
  final DateTime publishedAt;
  final String userId;
  final String userDisplayName;
  final String? userPhotoUrl;
  final String source;
  final ArticleCategory category;
  final List<String> tags;
  final String language;
  final int readingTimeMinutes;
  final ArticleLocation? location;
  final ArticleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final int favoriteCount;
  final bool isDeleted;
  final DateTime? deletedAt;

  const JournalistArticleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.urlToImage,
    required this.publishedAt,
    required this.userId,
    required this.userDisplayName,
    this.userPhotoUrl,
    required this.source,
    required this.category,
    required this.tags,
    required this.language,
    required this.readingTimeMinutes,
    this.location,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.viewCount,
    required this.favoriteCount,
    this.isDeleted = false,
    this.deletedAt,
  });

  static int estimateReadingTime(String content) {
    if (content.isEmpty) return 1;
    final wordCount = content.trim().split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil().clamp(1, double.maxFinite.toInt());
  }

  JournalistArticleEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? urlToImage,
    DateTime? publishedAt,
    String? userId,
    String? userDisplayName,
    Object? userPhotoUrl = _sentinel,
    String? source,
    ArticleCategory? category,
    List<String>? tags,
    String? language,
    int? readingTimeMinutes,
    Object? location = _sentinel,
    ArticleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    int? favoriteCount,
    bool? isDeleted,
    Object? deletedAt = _sentinel,
  }) {
    return JournalistArticleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userPhotoUrl:
          userPhotoUrl == _sentinel ? this.userPhotoUrl : userPhotoUrl as String?,
      source: source ?? this.source,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      language: language ?? this.language,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      location: location == _sentinel ? this.location : location as ArticleLocation?,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt == _sentinel ? this.deletedAt : deletedAt as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        urlToImage,
        publishedAt,
        userId,
        userDisplayName,
        userPhotoUrl,
        source,
        category,
        tags,
        language,
        readingTimeMinutes,
        location,
        status,
        createdAt,
        updatedAt,
        viewCount,
        favoriteCount,
        isDeleted,
        deletedAt,
      ];
}

const _sentinel = Object();
