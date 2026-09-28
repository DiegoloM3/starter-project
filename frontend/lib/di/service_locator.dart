import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/di/connectivity_bloc_service_locator/connectivity_bloc_service_locator.dart';
import 'package:news_app_clean_architecture/di/daily_news/article_blocs_service_locator.dart';
import 'package:news_app_clean_architecture/di/daily_news/article_repository_service_locator.dart';
import 'package:news_app_clean_architecture/di/daily_news/article_usecases_service_locator.dart';
import 'package:news_app_clean_architecture/di/daily_news/news_api_service_locator.dart';
import 'package:news_app_clean_architecture/di/daily_news/search_service_locator.dart';
import 'package:news_app_clean_architecture/di/database_service_locator/database_service_locator.dart';
import 'package:news_app_clean_architecture/di/dio_service_locator/dio_service_locator.dart';
import 'package:news_app_clean_architecture/di/user_articles/user_article_blocs_service_locator.dart';
import 'package:news_app_clean_architecture/di/user_articles/user_article_data_service_locator.dart';
import 'package:news_app_clean_architecture/di/user_articles/user_article_repository_service_locator.dart';
import 'package:news_app_clean_architecture/di/user_articles/user_article_usecases_service_locator.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ==================== DATABASE ====================
  await dataBaseServiceLocator();

  // ==================== DIO ====================
  dioServiceLocator();

  // ==================== CONNECTIVITY ====================
  connectivityBlocServiceLocator();

  // ==================== DAILY NEWS ====================
  newsApiServiceLocator();
  articleRepositoryServiceLocator();
  articleUseCasesServiceLocator();
  articleBlocsServiceLocator();
  searchServiceLocator();

  // ==================== USER ARTICLE ====================
  userArticleDataServiceLocator();
  userArticleRepositoryServiceLocator();
  userArticleUseCasesServiceLocator();
  userArticleBlocsServiceLocator();
}
