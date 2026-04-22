import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

// Elegant Imports (Barrels)
import 'package:news_app_clean_architecture/core/core.dart';
import 'package:news_app_clean_architecture/features/auth/auth.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/daily_news_domain.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/daily_news_presentation.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/reward/reward_cubit.dart';


// Data Sources (Non-exported for now to keep barrels semantic)
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firebase_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/chat_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/reward_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/storage_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/storage_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';



final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);
  
  // Firebase
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  sl.registerSingleton<FirebaseDataSource>(FirebaseDataSource(sl()));

  // Analytics
  sl.registerSingleton<AnalyticsRepository>(FirestoreAnalyticsImpl(sl(), sl()));

  // Auth
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl()));
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));

  // Dio (Local Backend / FastAPI)
  final backendDio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.backendBaseUrl,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 5000),
    ),
  );
  
  backendDio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      developer.log('DIO REQUEST[${options.method}] => PATH: ${options.path}', name: 'SymmetryNet');
      return handler.next(options);
    },
    onResponse: (response, handler) {
      developer.log('DIO RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}', name: 'SymmetryNet');
      return handler.next(response);
    },
    onError: (DioException e, handler) {
      developer.log('DIO ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}', name: 'SymmetryNet', error: e);
      return handler.next(e);
    },
  ));

  sl.registerSingleton<Dio>(backendDio, instanceName: 'backend');

  // API Services
  sl.registerSingleton<NewsApiService>(NewsApiService(sl(instanceName: 'backend')));
  sl.registerSingleton<ChatService>(ChatService(sl(instanceName: 'backend')));
  sl.registerSingleton<RewardApiService>(RewardApiService(sl(instanceName: 'backend')));

  // Repositories
  sl.registerSingleton<StorageRepository>(StorageRepositoryImpl(sl()));
  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(), sl(), sl())
  );
  
  // UseCases
  sl.registerSingleton<GetArticleUseCase>(
    GetArticleUseCase(sl())
  );

  sl.registerSingleton<PostArticleUseCase>(
    PostArticleUseCase(sl())
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

  // Blocs
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl(), sl())
  );

  sl.registerFactory<LocalArticleBloc>(
    ()=> LocalArticleBloc(sl(), sl(), sl())
  );

  sl.registerFactory<ChatBloc>(
    () => ChatBloc(sl(), sl())
  );

  sl.registerFactory<RewardCubit>(
    () => RewardCubit(sl())
  );
}