import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firebase_storage_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_article_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_user_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article_publish_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_management/article_management_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/upload_article/upload_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/edit_article/edit_article_cubit.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Firebase Services
  sl.registerSingleton<FirestoreArticleService>(
    FirestoreArticleServiceImpl(FirebaseFirestore.instance),
  );

  sl.registerSingleton<FirebaseStorageService>(
    FirebaseStorageServiceImpl(FirebaseStorage.instance),
  );

  // Remote Data Source
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  // Repository
  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  // Use Cases - Existing
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

  // Use Cases - Upload Feature
  sl.registerSingleton<UploadArticleUseCase>(
    UploadArticleUseCase(sl()),
  );

  sl.registerSingleton<GetUserArticlesUseCase>(
    GetUserArticlesUseCase(sl()),
  );

  sl.registerSingleton<DeleteArticleUseCase>(
    DeleteArticleUseCase(sl()),
  );

  sl.registerSingleton<UpdateArticleUseCase>(
    UpdateArticleUseCase(sl()),
  );

  sl.registerSingleton<UpdateArticlePublishStatusUseCase>(
    UpdateArticlePublishStatusUseCase(sl()),
  );

  // Blocs - Existing
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl())
  );

  sl.registerFactory<LocalArticleBloc>(
    ()=> LocalArticleBloc(sl(),sl(),sl())
  );

  // Cubits - Upload Feature
  sl.registerFactory<UploadArticleCubit>(
    () => UploadArticleCubit(uploadArticleUseCase: sl()),
  );

  sl.registerFactory<ArticleManagementCubit>(
    () => ArticleManagementCubit(
      getUserArticlesUseCase: sl(),
      deleteArticleUseCase: sl(),
      updatePublishStatusUseCase: sl(),
    ),
  );

  // Cubits - Edit Article Feature
  sl.registerFactory<EditArticleCubit>(
    () => EditArticleCubit(updateArticleUseCase: sl()),
  );

}