import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'DAO/article_dao.dart';

part 'app_database.g.dart';

/// Drift table definition — mirrors the old Floor 'article' table.
/// Named ArticlesTable to avoid collision with the ArticleEntity domain class.
class ArticlesTable extends Table {
  TextColumn get id => text().nullable()();
  TextColumn get authorDisplayName => text().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get urlToImage => text().nullable()();
  TextColumn get publishedAt => text().nullable()();
  TextColumn get content => text().nullable()();
  TextColumn get authorId => text().nullable()();
}

@DriftDatabase(tables: [ArticlesTable], daos: [ArticleDao])
/// Local Drift database for offline saved articles.
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // For testing — accepts a QueryExecutor directly.
  AppDatabase.forTesting(super.executor);

  // v3: `id` changed from INTEGER AUTOINCREMENT to TEXT (Firestore doc ids).
  // v1 on-device files still carry the INTEGER schema, so inserting a user
  // article's TEXT id crashed with SqliteException(20) datatype mismatch
  // while daily articles (NULL id → auto rowid) kept working.
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 3) {
          await _recreateArticlesTableWithTextId(m);
        }
      },
    );
  }

  /// Rebuilds [articlesTable] with the current TEXT-`id` DDL, preserving
  /// existing rows (`CAST(id AS TEXT)` keeps old INTEGER ids readable).
  /// Unknown v1 variants fall back to a clean table rather than crashing.
  Future<void> _recreateArticlesTableWithTextId(Migrator m) async {
    try {
      await customStatement(
        'ALTER TABLE articles_table RENAME TO articles_table_backup',
      );
      await m.createTable(articlesTable);
      await customStatement('''
        INSERT INTO articles_table
          (id, author_display_name, title, url_to_image,
           published_at, content, author_id)
        SELECT CAST(id AS TEXT), author_display_name, title, url_to_image,
          published_at, content, author_id
        FROM articles_table_backup
      ''');
      await customStatement('DROP TABLE articles_table_backup');
    } catch (_) {
      await customStatement('DROP TABLE IF EXISTS articles_table_backup');
      await customStatement('DROP TABLE IF EXISTS articles_table');
      await m.createTable(articlesTable);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app_database.db'));
    return NativeDatabase.createInBackground(file);
  });
}
