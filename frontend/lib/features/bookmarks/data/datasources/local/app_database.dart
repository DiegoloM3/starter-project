import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'dao/bookmark_dao.dart';
import 'tables/bookmarks_table.dart';

part 'app_database.g.dart';

/// Central Drift database for the application.
///
/// Schema history:
/// - v1: `articles` table (daily_news local saves — now superseded)
/// - v2: `bookmarks` table (unified cross-source bookmarking)
@DriftDatabase(tables: [Bookmarks], daos: [BookmarkDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v1 had a standalone `articles` table for saved news articles.
        // That data is intentionally not migrated — the new unified
        // bookmarks table supersedes it.
        await customStatement('DROP TABLE IF EXISTS articles');
        await m.createTable(bookmarks);
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'app_database');
}
