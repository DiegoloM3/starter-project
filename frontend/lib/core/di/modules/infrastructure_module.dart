import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/features/bookmarks/data/datasources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_client.dart';

@module
abstract class InfrastructureModule {
  @singleton
  AppDatabase get appDatabase => AppDatabase();

  @singleton
  Dio get dio => Dio();

  @singleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @singleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;

  @singleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;

  @singleton
  NewsApiClient newsApiClient(Dio dio) => NewsApiClient(dio);
}
