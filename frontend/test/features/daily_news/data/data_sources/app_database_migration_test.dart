import 'package:floor/floor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/cached_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/search_history_model.dart';
import 'package:sqflite/sqflite.dart' show OpenDatabaseOptions;

/// A phone that installed the starter app has a version-1 database. Opening
/// it with today's app must run every migration without crashing.
void main() {
  const name = 'migration_test.db';

  tearDown(() async {
    await sqfliteDatabaseFactory
        .deleteDatabase(await sqfliteDatabaseFactory.getDatabasePath(name));
  });

  test('upgrades a version-1 database all the way to the current schema',
      () async {
    final path = await sqfliteDatabaseFactory.getDatabasePath(name);
    await sqfliteDatabaseFactory.deleteDatabase(path);
    // The starter's schema, exactly as its generated code created it.
    final old = await sqfliteDatabaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) => db.execute(
            'CREATE TABLE IF NOT EXISTS `article` (`id` INTEGER, `author` TEXT, '
            '`title` TEXT, `description` TEXT, `url` TEXT, `urlToImage` TEXT, '
            '`publishedAt` TEXT, `content` TEXT, PRIMARY KEY (`id`))'),
      ),
    );
    await old.insert('article', {'title': 'Saved before', 'url': 'u1'});
    await old.close();

    final database = await $FloorAppDatabase.databaseBuilder(name).addMigrations(
        [migration1To2, migration2To3, migration3To4, migration4To5]).build();
    addTearDown(database.close);

    // Version 5 scopes saved articles to whoever saved them -- this row
    // predates that and so has no recorded owner, which means it correctly
    // stops showing up for anyone rather than being guessed at (see
    // migration4To5's own doc comment). It isn't lost from the database,
    // just no longer reachable through the scoped query any real screen
    // uses.
    expect(await database.articleDAO.getArticles('any-uid'), isEmpty);
    await database.searchHistoryDAO
        .insertSearch(const SearchHistoryModel(text: 'climate', searchedAt: 1));
    expect(await database.searchHistoryDAO.getRecentSearches(), hasLength(1));
    await database.cachedArticleDAO.insertArticles([
      const CachedArticleModel(
          category: 'top', position: 0, savedAt: 1, title: 'Offline story'),
    ]);
    expect(
        await database.cachedArticleDAO.getCachedArticles('top'), hasLength(1));
  });

  test(
      'a version-4 database upgrades cleanly, and two accounts on the same '
      'phone see only their own saved articles -- regression: signing into '
      'a different account showed the previous account\'s saved list right '
      'back, since nothing distinguished whose rows were whose',
      () async {
    final path = await sqfliteDatabaseFactory.getDatabasePath(name);
    await sqfliteDatabaseFactory.deleteDatabase(path);
    final old = await sqfliteDatabaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, _) async {
          await db.execute(
              'CREATE TABLE IF NOT EXISTS `article` (`id` INTEGER, `author` TEXT, '
              '`title` TEXT, `description` TEXT, `url` TEXT, `urlToImage` TEXT, '
              '`publishedAt` TEXT, `content` TEXT, `sourceName` TEXT, '
              'PRIMARY KEY (`id`))');
          // A save made before any account existed on this install.
          await db.insert('article', {'title': 'Pre-migration', 'url': 'u0'});
        },
      ),
    );
    await old.close();

    final database = await $FloorAppDatabase
        .databaseBuilder(name)
        .addMigrations([migration4To5]).build();
    addTearDown(database.close);

    expect(await database.articleDAO.getArticles('userA'), isEmpty);

    await database.articleDAO.insertArticle(
        const ArticleModel(url: 'u1', title: 'Saved by A', savedBy: 'userA'));
    await database.articleDAO.insertArticle(
        const ArticleModel(url: 'u2', title: 'Saved by B', savedBy: 'userB'));

    final aArticles = await database.articleDAO.getArticles('userA');
    expect(aArticles.map((a) => a.title), ['Saved by A']);
    final bArticles = await database.articleDAO.getArticles('userB');
    expect(bArticles.map((a) => a.title), ['Saved by B']);
  });
}
