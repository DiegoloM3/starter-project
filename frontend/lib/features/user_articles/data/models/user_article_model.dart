import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

/// DTO bridging Firestore JSON and [UserArticleEntity].
///
/// Kept as a plain class (not freezed) because the Firestore `Timestamp`
/// type fights `json_serializable` and we only need two converters. The
/// field list is a direct mirror of `backend/docs/DB_SCHEMA.md`.
class UserArticleModel {
  const UserArticleModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.description,
    required this.content,
    required this.thumbnailURL,
    required this.status,
    required this.publishedAt,
    required this.updatedAt,
    this.tags = const <String>[],
  });

  factory UserArticleModel.fromFirestore(Map<String, dynamic> data) {
    return UserArticleModel(
      id: data['id'] as String,
      authorId: data['authorId'] as String,
      authorName: data['authorName'] as String,
      title: data['title'] as String,
      description: (data['description'] as String?) ?? '',
      content: data['content'] as String,
      thumbnailURL: data['thumbnailURL'] as String,
      status: data['status'] as String? ?? 'draft',
      publishedAt: _asDate(data['publishedAt']),
      updatedAt: _asDate(data['updatedAt']),
      tags:
          (data['tags'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
    );
  }

  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String description;
  final String content;
  final String thumbnailURL;
  final String status;
  final DateTime publishedAt;
  final DateTime updatedAt;
  final List<String> tags;

  /// Builds the payload used for *create* writes. `publishedAt`/`updatedAt`
  /// are not here — the data source stamps them with `serverTimestamp()`
  /// so the rules predicate `data.publishedAt == request.time` holds.
  static Map<String, dynamic> createPayload({
    required String id,
    required String authorId,
    required String authorName,
    required String title,
    required String description,
    required String content,
    required String thumbnailURL,
    required List<String> tags,
    String status = 'published',
  }) {
    return <String, dynamic>{
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'description': description,
      'content': content,
      'thumbnailURL': thumbnailURL,
      'status': status,
      'tags': tags,
    };
  }

  /// Payload for *update* writes. Excludes `id`, `authorId` and
  /// `publishedAt` to keep the rule check that these fields are immutable.
  static Map<String, dynamic> updatePayload({
    required String title,
    required String description,
    required String content,
    required String thumbnailURL,
    required List<String> tags,
  }) {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'content': content,
      'thumbnailURL': thumbnailURL,
      'tags': tags,
    };
  }

  UserArticleEntity toEntity() {
    return UserArticleEntity(
      id: id,
      authorId: authorId,
      authorName: authorName,
      title: title,
      description: description,
      content: content,
      thumbnailURL: thumbnailURL,
      status: status == 'published'
          ? UserArticleStatus.published
          : UserArticleStatus.draft,
      tags: tags,
      publishedAt: publishedAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime _asDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    // Server-stamped writes arrive as null in the local write cache until
    // the server echoes back. Fall back to "now" so the UI can optimistic-
    // render; the next snapshot will carry the real timestamp.
    return DateTime.now();
  }
}
