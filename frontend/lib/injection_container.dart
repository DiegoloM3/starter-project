<<<<<<< HEAD
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
=======
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/analytics_service.dart';
>>>>>>> fbce432 (Finish PR (project setup))
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
<<<<<<< HEAD
=======
import 'features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'features/daily_news/data/models/article.dart';
>>>>>>> fbce432 (Finish PR (project setup))
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
<<<<<<< HEAD
=======
import 'features/article_upload/data/data_sources/article_upload_remote_datasource.dart';
import 'features/article_upload/data/data_sources/draft_local_datasource.dart';
import 'features/article_upload/data/repository/article_upload_repository_impl.dart';
import 'features/article_upload/data/repository/draft_repository_impl.dart';
import 'features/article_upload/domain/repository/article_upload_repository.dart';
import 'features/article_upload/domain/repository/draft_repository.dart';
import 'features/article_upload/domain/use_cases/upload_article_usecase.dart';
import 'features/article_upload/domain/use_cases/upload_article_thumbnail_usecase.dart';
import 'features/article_upload/domain/use_cases/get_upload_articles_usecase.dart';
import 'features/article_upload/domain/use_cases/get_all_articles_usecase.dart';
import 'features/article_upload/domain/use_cases/save_draft_usecase.dart';
import 'features/article_upload/domain/use_cases/load_draft_usecase.dart';
import 'features/article_upload/domain/use_cases/clear_draft_usecase.dart';
import 'features/article_upload/domain/use_cases/increment_article_views_usecase.dart';
import 'features/article_upload/presentation/bloc/article_upload_cubit.dart';

// Web stubs — avoid SQLite/WASM on web (local saved-articles only; upload works normally)
class _WebArticleDao implements ArticleDao {
  @override Future<void> insertArticle(ArticleModel article) async {}
  @override Future<void> deleteArticle(ArticleModel article) async {}
  @override Future<List<ArticleModel>> getArticles() async => [];
}

class _WebAppDatabase extends AppDatabase {
  _WebAppDatabase() {
    changeListener = StreamController<String>.broadcast();
  }
  @override ArticleDao get articleDao => _WebArticleDao();
  @override Future<void> close() async => changeListener.close();
}
>>>>>>> fbce432 (Finish PR (project setup))

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
<<<<<<< HEAD

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);
  
=======
  final database = kIsWeb
      ? _WebAppDatabase() as AppDatabase
      : await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

>>>>>>> fbce432 (Finish PR (project setup))
  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(
<<<<<<< HEAD
    ArticleRepositoryImpl(sl(),sl())
  );
  
=======
    ArticleRepositoryImpl(sl(), sl())
  );

>>>>>>> fbce432 (Finish PR (project setup))
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
<<<<<<< HEAD
  
=======

>>>>>>> fbce432 (Finish PR (project setup))
  sl.registerSingleton<RemoveArticleUseCase>(
    RemoveArticleUseCase(sl())
  );

<<<<<<< HEAD

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl())
  );

  sl.registerFactory<LocalArticleBloc>(
    ()=> LocalArticleBloc(sl(),sl(),sl())
  );


}
=======
  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
    () => RemoteArticlesBloc(sl())
  );

  sl.registerFactory<LocalArticlesBloc>(
    () => LocalArticlesBloc(sl(), sl(), sl())
  );

  // Analytics
  sl.registerLazySingleton<AnalyticsService>(() => ConsoleAnalyticsService());

  // Firebase instances
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  sl.registerLazySingleton<FirebaseStorage>(
    () => FirebaseStorage.instance,
  );

  // Article Upload — Data sources
  sl.registerLazySingleton<ArticleUploadRemoteDataSource>(
    () => ArticleUploadRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<DraftLocalDataSource>(
    () => DraftLocalDataSourceImpl(sl()),
  );

  // Article Upload — Repositories
  sl.registerLazySingleton<ArticleUploadRepository>(
    () => ArticleUploadRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DraftRepository>(
    () => DraftRepositoryImpl(sl()),
  );

  // Article Upload — Use cases
  sl.registerLazySingleton(() => UploadArticleUseCase(sl()));
  sl.registerLazySingleton(() => UploadArticleThumbnailUseCase(sl()));
  sl.registerLazySingleton(() => GetMyArticlesUseCase(sl()));
  sl.registerLazySingleton(() => GetAllArticlesUseCase(sl()));
  sl.registerLazySingleton(() => SaveDraftUseCase(sl()));
  sl.registerLazySingleton(() => LoadDraftUseCase(sl()));
  sl.registerLazySingleton(() => ClearDraftUseCase(sl()));
  sl.registerLazySingleton(() => IncrementArticleViewsUseCase(sl()));

  // Article Upload — Cubit (factory: stateful per screen)
  sl.registerFactory(
    () => ArticleUploadCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );
}
>>>>>>> fbce432 (Finish PR (project setup))
