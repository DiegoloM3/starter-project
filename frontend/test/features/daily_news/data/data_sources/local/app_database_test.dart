import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/saved_article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/migrations.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../../helpers/fixtures.dart';

/// Exercises the real Floor database on the host through sqflite_ffi, so the
/// DAO queries, the type converters and the migrations are verified against
/// SQLite rather than against mocks.

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  const me = 'uid-me';
  const other = 'uid-other';

  group('SavedArticleDao', () {
    late AppDatabase database;
    late SavedArticleDao dao;

    setUp(() async {
      database = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
      dao = database.savedArticleDao;
    });

    tearDown(() => database.close());

    test('round-trips an article through the converters', () async {
      final article = buildUserArticle(publishedAt: DateTime.utc(2026, 9, 15, 10, 30));

      await dao.insertArticle(SavedArticleModel.fromEntity(article, ownerId: me));
      final stored = await dao.findById(me, article.id);

      expect(stored?.toEntity(), article);
      expect(stored?.source, ArticleSource.user);
      expect(stored?.publishedAt.isUtc, isTrue);
    });

    test('lists an owner\'s articles newest first', () async {
      final older = buildArticle(id: 'old', publishedAt: DateTime.utc(2026, 1, 1));
      final newer = buildArticle(id: 'new', publishedAt: DateTime.utc(2026, 6, 1));
      await dao.insertArticle(SavedArticleModel.fromEntity(older, ownerId: me));
      await dao.insertArticle(SavedArticleModel.fromEntity(newer, ownerId: me));

      expect((await dao.getArticles(me)).map((a) => a.id), ['new', 'old']);
    });

    test('two accounts keep separate bookmarks of the same article', () async {
      final article = buildArticle(id: 'shared');
      await dao.insertArticle(SavedArticleModel.fromEntity(article, ownerId: me));
      await dao.insertArticle(SavedArticleModel.fromEntity(article, ownerId: other));

      await dao.deleteById(other, 'shared');

      expect(await dao.findById(me, 'shared'), isNotNull);
      expect(await dao.findById(other, 'shared'), isNull);
      expect(await dao.getArticles(other), isEmpty);
    });

    test('saving the same article twice replaces instead of failing', () async {
      await dao.insertArticle(SavedArticleModel.fromEntity(buildArticle(id: 'same', title: 'First'), ownerId: me));
      await dao.insertArticle(SavedArticleModel.fromEntity(buildArticle(id: 'same', title: 'Second'), ownerId: me));

      expect((await dao.getArticles(me)).single.title, 'Second');
    });
  });

  group('migrations', () {
    late String path;

    setUp(() async {
      final directory = await Directory.systemTemp.createTemp('news_app_db_');
      path = '${directory.path}/app_database.db';
    });

    tearDown(() async {
      final directory = File(path).parent;
      if (await directory.exists()) await directory.delete(recursive: true);
    });

    test('from v2 the table is rebuilt per owner; bookmarks with no owner are dropped', () async {
      final v2 = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, _) => db.execute(
            'CREATE TABLE `saved_article` (`id` TEXT NOT NULL, `source` TEXT NOT NULL, '
            '`title` TEXT NOT NULL, `content` TEXT NOT NULL, `description` TEXT, '
            '`author` TEXT NOT NULL, `authorId` TEXT, `imageUrl` TEXT, `imagePath` TEXT, '
            '`url` TEXT, `publishedAt` INTEGER NOT NULL, PRIMARY KEY (`id`))',
          ),
        ),
      );
      await v2.insert('saved_article', {
        'id': 'orphan',
        'source': 'remote',
        'title': 'Saved before accounts existed',
        'content': 'body',
        'author': 'Ada',
        'publishedAt': DateTime.utc(2026, 1, 1).millisecondsSinceEpoch,
      });
      await v2.close();

      final migrated = await $FloorAppDatabase.databaseBuilder(path).addMigrations(migrations).build();

      final rows = await migrated.database.rawQuery('SELECT ownerId, id FROM saved_article');
      expect(rows, isEmpty);
      await migrated.savedArticleDao.insertArticle(SavedArticleModel.fromEntity(buildArticle(), ownerId: me));
      expect(await migrated.savedArticleDao.getArticles(me), hasLength(1));

      await migrated.close();
    });

    test('from v1 drops the legacy table and creates saved_article', () async {
      final legacy = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) => db.execute(
            'CREATE TABLE IF NOT EXISTS `article` (`id` INTEGER, `author` TEXT, '
            '`title` TEXT, PRIMARY KEY (`id`))',
          ),
        ),
      );
      await legacy.insert('article', {'id': 1, 'author': 'x', 'title': 'legacy'});
      await legacy.close();

      final migrated = await $FloorAppDatabase.databaseBuilder(path).addMigrations(migrations).build();

      final tables = await migrated.database.rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'");
      final names = tables.map((row) => row['name']).toSet();
      expect(names, contains('saved_article'));
      expect(names, isNot(contains('article')));

      await migrated.close();
    });
  });
}
