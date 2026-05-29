import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:floor/floor.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';

final _migration1to2 = Migration(1, 2, (database) async {
  await database.execute('DROP TABLE IF EXISTS article');
  await database.execute(
    'CREATE TABLE IF NOT EXISTS `article` ('
    '`id` TEXT, '
    '`title` TEXT, '
    '`description` TEXT, '
    '`content` TEXT, '
    '`authorId` TEXT, '
    '`authorName` TEXT, '
    '`thumbnailUrl` TEXT, '
    '`thumbnailPath` TEXT, '
    '`url` TEXT, '
    '`publishedAt` TEXT, '
    '`createdAt` TEXT, '
    '`updatedAt` TEXT, '
    '`status` TEXT, '
    '`isDeleted` INTEGER, '
    '`readingTimeMinutes` INTEGER, '
    'PRIMARY KEY (`id`))',
  );
});

Future<void> registerCoreModule(GetIt sl) async {
  final database = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .addMigrations([_migration1to2])
      .build();
  sl.registerSingleton<AppDatabase>(database);

  sl.registerSingleton<Dio>(Dio());

  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
}
