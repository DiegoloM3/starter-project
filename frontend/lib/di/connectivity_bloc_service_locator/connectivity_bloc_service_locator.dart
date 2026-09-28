import 'package:news_app_clean_architecture/core/services/connectivity_service.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';
import 'package:news_app_clean_architecture/shared/bloc/connectivity/connectivity_bloc.dart';

void connectivityBlocServiceLocator() {
  getIt.registerSingleton<ConnectivityBloc>(
    ConnectivityBloc(service: ConnectivityService()),
  );
}