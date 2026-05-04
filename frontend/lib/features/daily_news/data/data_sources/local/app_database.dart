
import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/local/draft_dao.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/models/draft_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import '../../models/article.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';
part 'app_database.g.dart';

final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS draft_articles (
      draftId INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      content TEXT NOT NULL,
      localImagePath TEXT,
      categoryRaw TEXT,
      tagsRaw TEXT NOT NULL,
      language TEXT NOT NULL,
      locationLat REAL,
      locationLng REAL,
      locationPlaceName TEXT,
      lastSavedAtMillis INTEGER NOT NULL
    )
  ''');
});

@Database(version: 2, entities: [ArticleModel, DraftArticleModel])
abstract class AppDatabase extends FloorDatabase {
  ArticleDao get articleDAO;
  DraftDao get draftDao;
}
