import '../../domain/entities/article_status.dart';
import '../../domain/entities/journalist_article.dart';

/// Data layer view of [JournalistArticleEntity], shaped like the Firestore
/// document described in `backend/docs/DB_SCHEMA.md`.
///
/// The document field is `thumbnailURL` while the entity property is
/// `thumbnailUrl`: the schema was written before the entity and is what the
/// security rules check, so the mapping happens here rather than renaming
/// either side.
class JournalistArticleModel extends JournalistArticleEntity {
  const JournalistArticleModel({
    super.id,
    super.title,
    super.description,
    super.content,
    super.author,
    super.userId,
    super.thumbnailUrl,
    super.status,
    super.viewCount,
    super.publishedAt,
    super.createdAt,
    super.updatedAt,
  });

  factory JournalistArticleModel.fromRawData(
    String id,
    Map<String, dynamic> data,
  ) {
    return JournalistArticleModel(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      content: data['content'] as String? ?? '',
      author: data['author'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      thumbnailUrl: data['thumbnailURL'] as String? ?? '',
      status: _statusFromRawData(data['status']),
      viewCount: (data['viewCount'] as num?)?.toInt() ?? 0,
      publishedAt: _dateFromRawData(data['publishedAt']),
      createdAt: _dateFromRawData(data['createdAt']),
      updatedAt: _dateFromRawData(data['updatedAt']),
    );
  }

  factory JournalistArticleModel.fromEntity(JournalistArticleEntity article) {
    return JournalistArticleModel(
      id: article.id,
      title: article.title,
      description: article.description,
      content: article.content,
      author: article.author,
      userId: article.userId,
      thumbnailUrl: article.thumbnailUrl,
      status: article.status,
      viewCount: article.viewCount,
      publishedAt: article.publishedAt,
      createdAt: article.createdAt,
      updatedAt: article.updatedAt,
    );
  }

  /// The document body, without the id: the backend keeps that in the document
  /// key, and `firestore.rules` never looks at an `id` field.
  ///
  /// Dates leave here as plain [DateTime]s. Turning them into the provider's
  /// own timestamp type is the data source's job, which is the only place
  /// allowed to know which provider is behind this (rule 1.2.4).
  Map<String, dynamic> toRawData() {
    return <String, dynamic>{
      ...toRawDataForUpdate(),
      'userId': userId,
      'viewCount': viewCount,
      'createdAt': createdAt,
    };
  }

  /// The fields an author may change, for an update that writes only the keys
  /// it names.
  ///
  /// `userId`, `createdAt` and `viewCount` are deliberately left out. An
  /// update only writes the keys it names, so leaving them out means the
  /// author's edit cannot touch them — which is exactly what the rules
  /// demand. Sending `viewCount` back would in fact break editing: the author
  /// would be writing the count they loaded, and any reader who opened the
  /// article in the meantime would have made it stale, so the rule comparing
  /// it to the stored one would reject the edit.
  Map<String, dynamic> toRawDataForUpdate() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'thumbnailURL': thumbnailUrl,
      'status': status.value,
      'publishedAt': publishedAt,
      'updatedAt': updatedAt,
    };
  }

  JournalistArticleEntity toEntity() {
    return JournalistArticleEntity(
      id: id,
      title: title,
      description: description,
      content: content,
      author: author,
      userId: userId,
      thumbnailUrl: thumbnailUrl,
      status: status,
      viewCount: viewCount,
      publishedAt: publishedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// An unknown or missing status is read as a draft: the safe reading, since
  /// a draft is the private one.
  static ArticleStatus _statusFromRawData(Object? rawStatus) {
    return ArticleStatus.values.firstWhere(
      (status) => status.value == rawStatus,
      orElse: () => ArticleStatus.draft,
    );
  }

  /// Dates arrive already converted to Dart by the data source, so anything
  /// else — a missing field, or a provider type that was not translated — is
  /// read as "no date" rather than crashing the parse.
  static DateTime? _dateFromRawData(Object? rawDate) {
    return rawDate is DateTime ? rawDate : null;
  }
}
