import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/community_articles/data/data_sources/remote/community_article_firestore_datasource.dart';
import 'package:news_app_clean_architecture/features/community_articles/data/data_sources/remote/community_article_remote_datasource.dart';
import 'package:news_app_clean_architecture/features/community_articles/data/repository/community_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_local_datasource.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_local_datasource_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Firebase
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  // Data sources
  sl.registerSingleton<ArticleLocalDataSource>(
    ArticleLocalDataSourceImpl(database.articleDAO),
  );

  sl.registerSingleton<CommunityArticleRemoteDataSource>(
    CommunityArticleFirestoreDataSource(sl(), sl()),
  );

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(), sl()),
  );

  sl.registerSingleton<CommunityArticleRepository>(
    CommunityArticleRepositoryImpl(sl()),
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


  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl())
  );

  sl.registerFactory<LocalArticleBloc>(
    ()=> LocalArticleBloc(sl(),sl(),sl())
  );

  sl.registerFactory<CommunityFeedCubit>(
    () => CommunityFeedCubit(sl()),
  );


}