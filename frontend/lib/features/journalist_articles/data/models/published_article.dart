import '../../domain/entities/article_draft.dart';
import '../../domain/entities/published_article.dart';

/// Maps the `articles/{articleId}` documents described in backend/docs/DB_SCHEMA.md.
///
/// The data source hands over Dart primitives only (the document id as `id` and
/// `publishedAt` already converted to a [DateTime]), so this class does not depend on Firebase.
class PublishedArticleModel extends PublishedArticleEntity {
  static const String idKey = 'id';
  static const String titleField = 'title';
  static const String contentField = 'content';
  static const String descriptionField = 'description';
  static const String authorField = 'author';
  static const String thumbnailUrlField = 'thumbnailURL';
  static const String publishedAtField = 'publishedAt';

  const PublishedArticleModel({
    required super.id,
    required super.title,
    required super.content,
    required super.description,
    required super.author,
    required super.thumbnailUrl,
    required super.publishedAt,
  });

  /// Throws a [FormatException] when a field is missing or has the wrong type.
  factory PublishedArticleModel.fromRawData(Map<String, dynamic> data) {
    return PublishedArticleModel(
      id: _required<String>(data, idKey),
      title: _required<String>(data, titleField),
      content: _required<String>(data, contentField),
      description: _required<String>(data, descriptionField),
      author: _required<String>(data, authorField),
      thumbnailUrl: _required<String>(data, thumbnailUrlField),
      publishedAt: _required<DateTime>(data, publishedAtField),
    );
  }

  /// Fields of a new document, except `publishedAt`, which the data source sets to the server time.
  static Map<String, Object> newDocumentFields(ArticleDraftEntity draft, String thumbnailUrl) {
    return {
      titleField: draft.title,
      contentField: draft.content,
      descriptionField: draft.description,
      authorField: draft.author,
      thumbnailUrlField: thumbnailUrl,
    };
  }

  PublishedArticleEntity toEntity() {
    return PublishedArticleEntity(
      id: id,
      title: title,
      content: content,
      description: description,
      author: author,
      thumbnailUrl: thumbnailUrl,
      publishedAt: publishedAt,
    );
  }

  static T _required<T>(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! T) {
      throw FormatException('Article "${data[idKey]}" has an invalid "$key": $value');
    }
    return value;
  }
}
