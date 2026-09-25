import 'dart:async';

import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/cached_article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/search_history_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../models/article.dart';
import '../../models/cached_article_model.dart';
import '../../models/search_history_model.dart';

part 'app_database.g.dart';

@Database(
  version: 5,
  entities: [ArticleModel, SearchHistoryModel, CachedArticleModel],
)
abstract class AppDatabase extends FloorDatabase {
  ArticleDao get articleDAO;

  SearchHistoryDao get searchHistoryDAO;

  CachedArticleDao get cachedArticleDAO;
}

/// Version 2 added the article's source name. Adding a nullable column keeps
/// every article already saved on the phone; older ones just have no source.
final migration1To2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE article ADD COLUMN sourceName TEXT');
});

/// Version 3 added recent searches, in a table of their own.
final migration2To3 = Migration(2, 3, (database) async {
  await database.execute(_createSearchHistoryTable);
});

const _createSearchHistoryTable =
    'CREATE TABLE IF NOT EXISTS `search_history` (`text` TEXT NOT NULL, '
    '`searchedAt` INTEGER NOT NULL, PRIMARY KEY (`text`))';

/// Version 4 added the offline copy of the feed, in a table of its own.
final migration3To4 = Migration(3, 4, (database) async {
  await database.execute(_createCachedArticleTable);
});

const _createCachedArticleTable =
    'CREATE TABLE IF NOT EXISTS `cached_article` ('
    '`category` TEXT NOT NULL, `position` INTEGER NOT NULL, '
    '`savedAt` INTEGER NOT NULL, `id` INTEGER, `author` TEXT, `title` TEXT, '
    '`description` TEXT, `url` TEXT, `urlToImage` TEXT, `publishedAt` TEXT, '
    '`content` TEXT, `sourceName` TEXT, '
    'PRIMARY KEY (`category`, `position`))';

/// Version 5 scopes saved articles to whoever saved them. Before this, the
/// local `article` table had no idea a phone could ever hold more than one
/// person's saves -- signing out and into a different account showed the
/// previous account's saved list right back, since nothing distinguished
/// whose rows were whose. A nullable column keeps every row already saved
/// on the phone; they just have no owner recorded, so none of them show up
/// for anyone until re-saved -- the safe failure mode for "we genuinely
/// don't know whose these were", rather than guessing wrong.
final migration4To5 = Migration(4, 5, (database) async {
  await database.execute('ALTER TABLE article ADD COLUMN savedBy TEXT');
});
