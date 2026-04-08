import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/upload_article/data/data_sources/upload_article_firebase_data_source.dart';
import 'package:news_app_clean_architecture/features/upload_article/data/repository/upload_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/upload_article_repository.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/get_my_uploaded_articles.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/upload_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/my_uploaded_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/upload_article_cubit.dart';
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

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<UploadArticleFirebaseDataSource>(
    UploadArticleFirebaseDataSource(sl(), sl(), sl()),
  );

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(),sl())
  );

  sl.registerSingleton<UploadArticleRepository>(
    UploadArticleRepositoryImpl(sl()),
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

  sl.registerSingleton<UploadArticleUseCase>(
    UploadArticleUseCase(sl()),
  );

  sl.registerSingleton<GetMyUploadedArticlesUseCase>(
    GetMyUploadedArticlesUseCase(sl()),
  );


  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl())
  );

  sl.registerFactory<LocalArticleBloc>(
    ()=> LocalArticleBloc(sl(),sl(),sl())
  );

  sl.registerFactory<UploadArticleCubit>(
    () => UploadArticleCubit(sl()),
  );

  sl.registerFactory<MyUploadedArticlesCubit>(
    () => MyUploadedArticlesCubit(sl()),
  );


}