

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';

void dioServiceLocator(){
  getIt.registerSingleton<Dio>(Dio());
}