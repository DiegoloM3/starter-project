

import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';

void articleRepositoryServiceLocator() {
  getIt.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(
      newsApiService: getIt<NewsApiService>(),
      appDatabase: getIt<AppDatabase>(),
    ),
  );
}