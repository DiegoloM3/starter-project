// coverage:ignore-file
// Floor database definition; the DAO is exercised through the repository tests.
// Floor marks type converters as experimental although they have been stable since 1.0.
// ignore_for_file: experimental_member_use

import 'dart:async';

import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/saved_article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/converters/article_source_converter.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/converters/date_time_converter.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/converters/news_category_converter.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/migrations.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_article_model.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@TypeConverters([DateTimeConverter, ArticleSourceConverter, NewsCategoryConverter])
@Database(version: 4, entities: [SavedArticleModel])
abstract class AppDatabase extends FloorDatabase {
  static const String fileName = 'app_database.db';

  SavedArticleDao get savedArticleDao;

  /// Opens (and migrates) the on-device database.
  static Future<AppDatabase> open() {
    return $FloorAppDatabase
        .databaseBuilder(fileName)
        .addMigrations(migrations)
        .build();
  }
}
