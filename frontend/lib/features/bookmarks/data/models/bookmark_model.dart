import '../../domain/entities/bookmark_entity.dart';

/// Data model for a bookmark entry stored in the local Drift database.
///
/// Extends [BookmarkEntity] and adds serialization factories.
class BookmarkModel extends BookmarkEntity {
  const BookmarkModel({
    required super.sourceId,
    required super.source,
    super.title,
    super.description,
    super.imageUrl,
    super.url,
    super.author,
    super.publishedAt,
    super.content,
  });

  /// Creates a [BookmarkModel] from an existing [BookmarkEntity].
  factory BookmarkModel.fromEntity(BookmarkEntity entity) {
    return BookmarkModel(
      sourceId: entity.sourceId,
      source: entity.source,
      title: entity.title,
      description: entity.description,
      imageUrl: entity.imageUrl,
      url: entity.url,
      author: entity.author,
      publishedAt: entity.publishedAt,
      content: entity.content,
    );
  }

  /// Converts this model back to a pure domain [BookmarkEntity].
  BookmarkEntity toEntity() {
    return BookmarkEntity(
      sourceId: sourceId,
      source: source,
      title: title,
      description: description,
      imageUrl: imageUrl,
      url: url,
      author: author,
      publishedAt: publishedAt,
      content: content,
    );
  }
}
