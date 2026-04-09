import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/config/routes/go_router_config.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_service.dart.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_service_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/login/data/data_sources/remote/users_service.dart';
import 'package:news_app_clean_architecture/features/login/data/data_sources/remote/users_service_impl.dart';
import 'package:news_app_clean_architecture/features/login/data/repository/user_repository_impl.dart';
import 'package:news_app_clean_architecture/features/login/domain/repository/user_repository.dart';
import 'package:news_app_clean_architecture/features/login/domain/usecases/create_user.dart';
import 'package:news_app_clean_architecture/features/login/domain/usecases/login_stream.dart';
import 'package:news_app_clean_architecture/features/login/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:news_app_clean_architecture/features/login/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_articles.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final database =
      await $FroomAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsService>(NewsServiceImpl());

  sl.registerSingleton<UsersService>(UserServiceImpl());

  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl()));

  sl.registerSingleton<UserRepository>(UserRepositoryImpl(sl()));

  //UseCases
  sl.registerSingleton<GetArticlesUseCase>(GetArticlesUseCase(sl()));

  sl.registerSingleton<GetSavedArticlesUseCase>(GetSavedArticlesUseCase(sl()));

  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  sl.registerSingleton<LoginStreamUseCase>(LoginStreamUseCase(sl()));

  sl.registerSingleton<SignInWithEmailAndPasswordUseCase>(
      SignInWithEmailAndPasswordUseCase(sl()));

  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl()));

  sl.registerSingleton<CreateUserUseCase>(CreateUserUseCase(sl()));

  sl.registerSingleton<CreateArticleUseCase>(CreateArticleUseCase(sl()));

  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
    () => RemoteArticlesBloc(
      sl(),
      sl(),
    ),
  );

  sl.registerLazySingleton<LocalArticleBloc>(() => LocalArticleBloc(
        sl(),
        sl(),
        sl(),
        sl(),
      ));

  sl.registerLazySingleton<LoginBloc>(
    () => LoginBloc(
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  // Go router
  sl.registerLazySingleton<GoRouterConfig>(
    () => GoRouterConfig(
      navigatorKey: GlobalKey<NavigatorState>(),
    ),
  );
}
