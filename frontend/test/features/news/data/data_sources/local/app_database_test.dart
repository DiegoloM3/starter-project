import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/local/article_local_mapper.dart';
import 'package:news_app_clean_architecture/features/news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  group('AppDatabase id migration (v1 INTEGER → v3 TEXT)', () {
    test(
        'migrates a v1 on-device file and keeps saved rows readable '
        'with TEXT ids', () async {
      // Replay the real scenario: a stale v1 file on disk, then a single
      // app-style open that must migrate it (one database per connection,
      // so no shared-executor races).
      final dir =
          await Directory.systemTemp.createTemp('drift_migration_test');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/app.db');

      // Seed the stale v1 file with raw sqlite: INTEGER AUTOINCREMENT id
      // plus the since-removed description/url columns.
      final raw = sqlite.sqlite3.open(file.path);
      raw.execute('''
        CREATE TABLE articles_table (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          author_display_name TEXT,
          title TEXT,
          description TEXT,
          url TEXT,
          url_to_image TEXT,
          published_at TEXT,
          content TEXT,
          author_id TEXT
        )
      ''');
      raw.execute(
        'INSERT INTO articles_table '
        '(author_display_name, title, url_to_image, published_at, content) '
        "VALUES ('John Doe', 'Old Title', 'https://example.com/i.jpg', "
        "'2024-01-01T00:00:00Z', 'Old content')",
      );
      raw.execute('PRAGMA user_version = 1');
      raw.dispose();

      final db = AppDatabase.forTesting(NativeDatabase(file));
      final rows = await db.articleDao.getArticles();

      expect(rows.length, 1);
      expect(rows.first.title, 'Old Title');
      expect(rows.first.id, isA<String>());
      await db.close();
    });

    test('round-trips a user article carrying a Firestore TEXT id',
        () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      const entity = ArticleEntity(
        id: 'hzGzJqMzH05QZqIEDNla',
        authorDisplayName: 'Camilo',
        title: 'News from Camilo',
        urlToImage: 'https://example.com/thumb.png',
        publishedAt: '2026-09-27T12:11:50.732200',
        content: 'offline copy',
        authorId: 'Te6Hkez6BJgnuZVCRIZhIAsMHXmM',
      );

      await db.articleDao.insertArticle(ArticleLocalMapper.toCompanion(
          ArticleModel.fromEntity(entity)));
      final rows = await db.articleDao.getArticles();

      expect(rows.length, 1);
      expect(rows.first.id, 'hzGzJqMzH05QZqIEDNla');
      expect(
        ArticleLocalMapper.fromRow(rows.first).toEntity(),
        entity,
      );
      await db.close();
    });

    test('deleteArticle removes only the matching row, including NULL ids',
        () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      const nullId = ArticleModel(
        authorDisplayName: 'John Doe',
        title: 'Daily Null',
        urlToImage: 'https://example.com/image.jpg',
        publishedAt: '2024-01-01T00:00:00Z',
        content: 'Daily Content',
      );
      const withId = ArticleModel(
        id: 'keep-me',
        authorDisplayName: 'Jane',
        title: 'Other',
        publishedAt: '2024-01-02T00:00:00Z',
        content: 'Other Content',
      );
      await db.articleDao
          .insertArticle(ArticleLocalMapper.toCompanion(nullId));
      await db.articleDao
          .insertArticle(ArticleLocalMapper.toCompanion(withId));

      final rows = await db.articleDao.getArticles();
      final target = rows.firstWhere((r) => r.title == 'Daily Null');
      await db.articleDao.deleteArticle(target);

      final remaining = await db.articleDao.getArticles();
      expect(remaining.length, 1);
      expect(remaining.first.id, 'keep-me');
      await db.close();
    });
  });
}
