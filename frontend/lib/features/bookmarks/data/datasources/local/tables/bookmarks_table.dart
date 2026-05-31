import 'package:drift/drift.dart';

/// Drift table for persisting user bookmarks locally.
///
/// The composite primary key (sourceId, source) ensures each article
/// can only be bookmarked once per source, regardless of article type.
class Bookmarks extends Table {
  /// Unique identifier for the article within its source.
  /// API articles use the article URL; community articles use Firestore document ID.
  TextColumn get sourceId => text()();

  /// The origin of the article — serialized [ArticleSource] enum name.
  TextColumn get source => text()();

  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get publishedAt => text().nullable()();
  TextColumn get content => text().nullable()();

  @override
  Set<Column> get primaryKey => {sourceId, source};
}
