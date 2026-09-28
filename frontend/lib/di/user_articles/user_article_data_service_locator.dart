
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/user_article_firestore_data_source.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';

void userArticleDataServiceLocator() {
  getIt.registerLazySingleton<UserArticleFirestoreDataSource>(
    () => UserArticleFirestoreDataSource(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    ),
  );
}