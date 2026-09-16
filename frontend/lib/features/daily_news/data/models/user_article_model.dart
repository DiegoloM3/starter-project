import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/thumbnail_reference.dart';

/// An article document from our own backend (`articles/{id}`), with the
/// field names of `backend/docs/DB_SCHEMA.md`.
///
/// The data source hands over timestamps already converted to [DateTime]
/// and adds the server-owned `createdAt` / `updatedAt` on write, so this
/// model stays free of Firestore types.
class UserArticleModel extends ArticleEntity {
  const UserArticleModel({
    required super.id,
    required super.title,
    required super.content,
    required super.author,
    required super.authorId,
    required super.publishedAt,
    super.category,
    super.description,
    super.imageUrl,
    super.imagePath,
  }) : super(source: ArticleSource.user);

  static const String fieldTitle = 'title';
  static const String fieldDescription = 'description';
  static const String fieldContent = 'content';
  static const String fieldAuthor = 'author';
  static const String fieldAuthorId = 'authorId';
  static const String fieldCategory = 'category';
  static const String fieldThumbnailUrl = 'thumbnailURL';
  static const String fieldThumbnailPath = 'thumbnailPath';
  static const String fieldPublishedAt = 'publishedAt';

  /// Builds a model from a document's data. Missing text fields fall back to
  /// empty strings and a missing date to the epoch, so a malformed document
  /// renders last instead of crashing the feed.
  factory UserArticleModel.fromRawData(String id, Map<String, dynamic> raw) {
    return UserArticleModel(
      id: id,
      title: _string(raw[fieldTitle]),
      content: _string(raw[fieldContent]),
      author: _string(raw[fieldAuthor]),
      authorId: _string(raw[fieldAuthorId]),
      category: NewsCategory.fromApiValue(raw[fieldCategory] as String?),
      description: _optional(raw[fieldDescription]),
      imageUrl: _optional(raw[fieldThumbnailUrl]),
      imagePath: _optional(raw[fieldThumbnailPath]),
      publishedAt: raw[fieldPublishedAt] is DateTime
          ? raw[fieldPublishedAt] as DateTime
          : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  /// The document a journalist's draft becomes.
  factory UserArticleModel.fromDraft({
    required String id,
    required ArticleDraft draft,
    required String authorId,
    required String authorName,
    ThumbnailReference? thumbnail,
  }) {
    return UserArticleModel(
      id: id,
      title: draft.trimmedTitle,
      content: draft.trimmedContent,
      description: draft.trimmedDescription,
      category: draft.category,
      author: authorName,
      authorId: authorId,
      imageUrl: thumbnail?.url,
      imagePath: thumbnail?.path,
      publishedAt: draft.publishedAt,
    );
  }

  /// Every schema field except the server timestamps. Absent optionals are
  /// written as `null`, as the rules require.
  Map<String, dynamic> toRawData() {
    return {
      fieldTitle: title,
      fieldDescription: description,
      fieldContent: content,
      fieldAuthor: author,
      fieldAuthorId: authorId,
      fieldCategory: category.apiValue,
      fieldThumbnailUrl: imageUrl,
      fieldThumbnailPath: imagePath,
      fieldPublishedAt: publishedAt,
    };
  }

  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      source: source,
      title: title,
      content: content,
      description: description,
      author: author,
      authorId: authorId,
      category: category,
      imageUrl: imageUrl,
      imagePath: imagePath,
      publishedAt: publishedAt,
    );
  }

  static String _string(Object? value) => value is String ? value : '';

  static String? _optional(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;
}
