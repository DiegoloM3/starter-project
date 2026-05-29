import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';
import '../../../../core/constants/constants.dart';

@Entity(tableName: 'article', primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    String? id,
    String? authorName,
    String? title,
    String? description,
    String? url,
    String? thumbnailUrl,
    String? publishedAt,
    String? content,
    String? authorId,
    String? thumbnailPath,
    String? createdAt,
    String? updatedAt,
    String? status,
    bool? isDeleted,
    int? readingTimeMinutes,
  }) : super(
    id: id,
    authorName: authorName,
    title: title,
    description: description,
    url: url,
    thumbnailUrl: thumbnailUrl,
    publishedAt: publishedAt,
    content: content,
    authorId: authorId,
    thumbnailPath: thumbnailPath,
    createdAt: createdAt,
    updatedAt: updatedAt,
    status: status,
    isDeleted: isDeleted,
    readingTimeMinutes: readingTimeMinutes,
  );

  factory ArticleModel.fromJson(Map<String, dynamic> map) {
    final url = map['url'] ?? '';
    return ArticleModel(
      // Deterministic id from the article URL so the same API article maps to
      // the same Firestore comment thread on every device (md5 is stable across
      // SDK versions/platforms, unlike String.hashCode). Not used for security.
      id: url.isNotEmpty ? md5.convert(utf8.encode(url)).toString() : null,
      authorName: map['author'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      url: url,
      thumbnailUrl: map['urlToImage'] != null && map['urlToImage'] != ""
          ? map['urlToImage']
          : kDefaultImage,
      publishedAt: map['publishedAt'] ?? "",
      content: map['content'] ?? "",
    );
  }

  factory ArticleModel.fromRawData(Map<String, dynamic> map) =>
      ArticleModel.fromJson(map);

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      authorName: entity.authorName,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      thumbnailUrl: entity.thumbnailUrl,
      publishedAt: entity.publishedAt,
      content: entity.content,
      authorId: entity.authorId,
      thumbnailPath: entity.thumbnailPath,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      status: entity.status,
      isDeleted: entity.isDeleted,
      readingTimeMinutes: entity.readingTimeMinutes,
    );
  }

  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      authorName: authorName,
      title: title,
      description: description,
      url: url,
      thumbnailUrl: thumbnailUrl,
      publishedAt: publishedAt,
      content: content,
      authorId: authorId,
      thumbnailPath: thumbnailPath,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
      isDeleted: isDeleted,
      readingTimeMinutes: readingTimeMinutes,
    );
  }

  /// Raw JSON map mirroring [fromJson]/[fromRawData] (the News API shape).
  /// Inverse of the parsing factory so an API article can round-trip.
  Map<String, dynamic> toJson() {
    return {
      'author': authorName,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': thumbnailUrl,
      'publishedAt': publishedAt,
      'content': content,
    };
  }

  /// Sentinel value for `createdAt`/`updatedAt` in the plain maps produced by
  /// [toFirestoreMap]/[toFirestoreUpdateMap]. The Firestore data source replaces
  /// it with `FieldValue.serverTimestamp()` before writing — this keeps the
  /// cloud_firestore dependency out of the model layer.
  static const String serverTimestampSentinel = '__server_timestamp__';

  /// Builds a model from already-parsed plain values. The Firestore data source
  /// converts `Timestamp` fields to ISO-8601 strings (or null) before calling
  /// this, so the model never touches a `Timestamp` directly.
  factory ArticleModel.fromFirestore(Map<String, dynamic> data) {
    return ArticleModel(
      id: data['id'] as String?,
      title: data['title'] as String?,
      description: data['description'] as String?,
      content: data['content'] as String?,
      authorId: data['authorId'] as String?,
      authorName: data['authorName'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      thumbnailPath: data['thumbnailPath'] as String?,
      url: data['url'] as String?,
      publishedAt: _timestampToString(data['publishedAt']),
      createdAt: _timestampToString(data['createdAt']),
      updatedAt: _timestampToString(data['updatedAt']),
      status: data['status'] as String?,
      isDeleted: data['isDeleted'] as bool?,
      readingTimeMinutes: data['readingTimeMinutes'] as int?,
    );
  }

  /// Plain-Dart Firestore payload. `publishedAt` is an ISO-8601 String or null;
  /// `createdAt`/`updatedAt` carry [serverTimestampSentinel]. The data source
  /// translates these into `Timestamp`/`FieldValue.serverTimestamp()` on write.
  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'thumbnailUrl': thumbnailUrl ?? '',
      'thumbnailPath': thumbnailPath ?? '',
      'publishedAt': publishedAt,
      'createdAt': serverTimestampSentinel,
      'updatedAt': serverTimestampSentinel,
      'status': status ?? ArticleStatus.draft,
      'isDeleted': isDeleted ?? false,
      'readingTimeMinutes': readingTimeMinutes ?? 1,
    };
  }

  /// For updates only — excludes immutable fields (id, authorId, createdAt).
  /// Same plain-Dart contract as [toFirestoreMap]: `publishedAt` is an ISO-8601
  /// String or null and `updatedAt` carries [serverTimestampSentinel].
  Map<String, dynamic> toFirestoreUpdateMap() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'authorName': authorName,
      'thumbnailUrl': thumbnailUrl ?? '',
      'thumbnailPath': thumbnailPath ?? '',
      'publishedAt': publishedAt,
      'updatedAt': serverTimestampSentinel,
      'status': status,
      'isDeleted': isDeleted,
      'readingTimeMinutes': readingTimeMinutes,
    };
  }

  static String? _timestampToString(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    return null;
  }
}