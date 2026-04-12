import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:news_app_clean_architecture/features/articles_upload/data/data_sources/local/article_upload_dao.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/data_sources/local/article_upload_floor_entity.dart';

part 'articles_local_database.g.dart';

@Database(version: 1, entities: [ArticleUploadFloorEntity])
abstract class ArticlesLocalDatabase extends FloorDatabase {
  ArticleUploadDao get articleUploadDao;
}
