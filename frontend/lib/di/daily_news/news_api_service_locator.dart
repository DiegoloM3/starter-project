
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';

void newsApiServiceLocator() {
  getIt.registerSingleton<NewsApiService>(NewsApiService(getIt<Dio>()));
}

