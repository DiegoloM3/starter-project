import 'package:news_app_clean_architecture/core/services/connectivity_service.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/user_article_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/repository/user_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';

void userArticleRepositoryServiceLocator() {
  getIt.registerLazySingleton<UserArticleRepository>(
    () => UserArticleRepositoryImpl(dataSource: getIt<UserArticleFirestoreDataSource>(),
     connectivityService: ConnectivityService(),),
  );
}