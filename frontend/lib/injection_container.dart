import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';

import 'config/locale/locale_cubit.dart';
import 'config/theme/theme_cubit.dart';
import 'core/data/data_sources/remote/current_user_data_source.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/data/repository/search_history_repository_impl.dart';
import 'features/daily_news/domain/repository/search_history_repository.dart';
import 'features/daily_news/domain/usecases/get_recent_searches.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/remove_search.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/domain/usecases/save_search.dart';
import 'features/daily_news/domain/usecases/search_articles.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'features/daily_news/presentation/bloc/search/search_cubit.dart';
import 'features/user_articles/data/data_sources/remote/user_article_firestore_data_source.dart';
import 'features/user_articles/data/data_sources/remote/user_article_storage_data_source.dart';
import 'features/user_articles/data/repository/user_article_repository_impl.dart';
import 'features/user_articles/domain/repository/user_article_repository.dart';
import 'features/user_articles/domain/usecases/create_user_article_usecase.dart';
import 'features/user_articles/domain/usecases/delete_user_article_usecase.dart';
import 'features/user_articles/domain/usecases/get_user_article_by_id_usecase.dart';
import 'features/user_articles/domain/usecases/get_user_articles_usecase.dart';
import 'features/user_articles/domain/usecases/update_user_article_usecase.dart';
import 'features/user_articles/presentation/bloc/detail/user_article_detail_cubit.dart';
import 'features/user_articles/presentation/bloc/feed/user_articles_feed_cubit.dart';
import 'features/user_articles/presentation/bloc/form/user_article_form_cubit.dart';
import 'shared/account/data/data_sources/remote/account_auth_data_source.dart';
import 'shared/account/data/data_sources/remote/google_identity_data_source.dart';
import 'shared/account/data/repository/account_repository_impl.dart';
import 'shared/account/domain/repository/account_content_repository.dart';
import 'shared/account/domain/repository/account_repository.dart';
import 'shared/account/domain/usecases/connect_account_usecase.dart';
import 'shared/account/domain/usecases/delete_account_usecase.dart';
import 'shared/account/domain/usecases/get_current_account_usecase.dart';
import 'shared/account/domain/usecases/sign_out_usecase.dart';
import 'shared/account/domain/usecases/switch_to_existing_account_usecase.dart';
import 'shared/account/domain/usecases/update_display_name_usecase.dart';
import 'shared/account/presentation/bloc/account_cubit.dart';
import 'shared/connectivity/data/data_sources/connectivity_data_source.dart';
import 'shared/connectivity/data/repository/connectivity_repository_impl.dart';
import 'shared/connectivity/domain/repository/connectivity_repository.dart';
import 'shared/connectivity/domain/usecases/watch_connectivity_usecase.dart';
import 'shared/connectivity/presentation/bloc/connectivity_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  final database = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .addMigrations(
          [migration1To2, migration2To3, migration3To4, migration4To5])
      .build();
  sl.registerSingleton<AppDatabase>(database);

  // Firebase Auth: registered early, ahead of ArticleRepositoryImpl below,
  // which now needs CurrentUserDataSource to scope saved articles to
  // whoever's actually signed in -- not just alongside UserArticles'/
  // account's own data sources further down, like before.
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<CurrentUserDataSource>(
    CurrentUserDataSource(sl())
  );

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(),sl(),sl())
  );
  
  //UseCases
  sl.registerSingleton<GetArticleUseCase>(
    GetArticleUseCase(sl())
  );

  sl.registerSingleton<GetSavedArticleUseCase>(
    GetSavedArticleUseCase(sl())
  );

  sl.registerSingleton<SaveArticleUseCase>(
    SaveArticleUseCase(sl())
  );
  
  sl.registerSingleton<RemoveArticleUseCase>(
    RemoveArticleUseCase(sl())
  );

  sl.registerSingleton<SearchArticlesUseCase>(
    SearchArticlesUseCase(sl())
  );

  sl.registerSingleton<SearchHistoryRepository>(
    SearchHistoryRepositoryImpl(sl())
  );

  sl.registerSingleton<GetRecentSearchesUseCase>(
    GetRecentSearchesUseCase(sl())
  );

  sl.registerSingleton<SaveSearchUseCase>(
    SaveSearchUseCase(sl())
  );

  sl.registerSingleton<RemoveSearchUseCase>(
    RemoveSearchUseCase(sl())
  );


  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl())
  );

  sl.registerFactory<SearchCubit>(
    () => SearchCubit(sl(), sl(), sl(), sl())
  );

  sl.registerFactory<LocalArticleBloc>(
    ()=> LocalArticleBloc(sl(),sl(),sl())
  );

  //UserArticles data sources
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  sl.registerSingleton<UserArticleFirestoreDataSource>(
    UserArticleFirestoreDataSource(sl())
  );

  sl.registerSingleton<UserArticleStorageDataSource>(
    UserArticleStorageDataSource(sl())
  );

  //UserArticles repository
  // One instance behind both interfaces: it owns the articles, so it's also
  // what deletes them when an account goes (AccountContentRepository).
  final userArticleRepository = UserArticleRepositoryImpl(sl(), sl(), sl());
  sl.registerSingleton<UserArticleRepository>(userArticleRepository);
  sl.registerSingleton<AccountContentRepository>(userArticleRepository);

  //UserArticles UseCases
  sl.registerSingleton<GetUserArticlesUseCase>(
    GetUserArticlesUseCase(sl())
  );

  sl.registerSingleton<GetUserArticleByIdUseCase>(
    GetUserArticleByIdUseCase(sl())
  );

  sl.registerSingleton<CreateUserArticleUseCase>(
    CreateUserArticleUseCase(sl())
  );

  sl.registerSingleton<UpdateUserArticleUseCase>(
    UpdateUserArticleUseCase(sl())
  );

  sl.registerSingleton<DeleteUserArticleUseCase>(
    DeleteUserArticleUseCase(sl())
  );

  //UserArticles Cubits
  sl.registerFactory<UserArticlesFeedCubit>(
    () => UserArticlesFeedCubit(sl())
  );

  sl.registerFactory<UserArticleDetailCubit>(
    () => UserArticleDetailCubit(sl(), sl())
  );

  sl.registerFactory<UserArticleFormCubit>(
    () => UserArticleFormCubit(sl(), sl(), sl(), sl())
  );

  //Account data sources -- singletons on purpose: both keep state between
  //calls (a pending account switch, google_sign_in's one-time initialize).
  sl.registerSingleton<GoogleSignIn>(GoogleSignIn.instance);

  sl.registerSingleton<AccountAuthDataSource>(
    AccountAuthDataSource(sl())
  );

  sl.registerSingleton<GoogleIdentityDataSource>(
    GoogleIdentityDataSource(sl())
  );

  //Account repository (shares CurrentUserDataSource with UserArticles)
  sl.registerSingleton<AccountRepository>(
    AccountRepositoryImpl(sl(), sl(), sl())
  );

  //Account UseCases
  sl.registerSingleton<GetCurrentAccountUseCase>(
    GetCurrentAccountUseCase(sl())
  );

  sl.registerSingleton<ConnectAccountUseCase>(
    ConnectAccountUseCase(sl())
  );

  sl.registerSingleton<SwitchToExistingAccountUseCase>(
    SwitchToExistingAccountUseCase(sl())
  );

  sl.registerSingleton<SignOutUseCase>(
    SignOutUseCase(sl())
  );

  sl.registerSingleton<DeleteAccountUseCase>(
    DeleteAccountUseCase(sl(), sl())
  );

  sl.registerSingleton<UpdateDisplayNameUseCase>(
    UpdateDisplayNameUseCase(sl())
  );

  //Account Cubit
  sl.registerFactory<AccountCubit>(
    () => AccountCubit(sl(), sl(), sl(), sl(), sl(), sl())
  );

  //Connectivity
  sl.registerSingleton<Connectivity>(Connectivity());

  sl.registerSingleton<ConnectivityDataSource>(
    ConnectivityDataSource(sl())
  );

  sl.registerSingleton<ConnectivityRepository>(
    ConnectivityRepositoryImpl(sl())
  );

  sl.registerSingleton<WatchConnectivityUseCase>(
    WatchConnectivityUseCase(sl())
  );

  // App-wide, single shared instance: one live subscription to the OS,
  // not one per screen that happens to care about it.
  sl.registerSingleton<ConnectivityCubit>(ConnectivityCubit(sl()));

  //Theme (app-wide, single shared instance -- see theme_cubit.dart)
  sl.registerSingleton<ThemeCubit>(ThemeCubit());

  //Language (app-wide, same reasoning as ThemeCubit)
  sl.registerSingleton<LocaleCubit>(LocaleCubit());

}