import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/device/gallery_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_thumbnail_storage_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/articles_firestore_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_headlines_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/published_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/published_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_thumbnail_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_thumbnail_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_news_feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_published_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/pick_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/publish/publish_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/use_cases/get_saved_article.dart';
import 'features/daily_news/domain/use_cases/remove_article.dart';
import 'features/daily_news/domain/use_cases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'firebase_options.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);
  
  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<NewsHeadlinesService>(NewsHeadlinesService(sl()));

  sl.registerSingleton<GalleryService>(GalleryService(ImagePicker()));

  sl.registerSingleton<ArticlesFirestoreService>(ArticlesFirestoreService(FirebaseFirestore.instance));

  sl.registerSingleton<ArticleThumbnailStorageService>(ArticleThumbnailStorageService(FirebaseStorage.instance));

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(),sl())
  );

  sl.registerSingleton<ArticleThumbnailRepository>(
    ArticleThumbnailRepositoryImpl(sl())
  );

  sl.registerSingleton<PublishedArticleRepository>(
    PublishedArticleRepositoryImpl(sl(), sl())
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

  sl.registerSingleton<GetPublishedArticlesUseCase>(
    GetPublishedArticlesUseCase(sl())
  );

  sl.registerSingleton<GetNewsFeedUseCase>(
    GetNewsFeedUseCase(sl(), sl())
  );

  sl.registerSingleton<PublishArticleUseCase>(
    PublishArticleUseCase(sl())
  );

  sl.registerSingleton<PickArticleThumbnailUseCase>(
    PickArticleThumbnailUseCase(sl())
  );


  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl())
  );

  sl.registerFactory<LocalArticleBloc>(
    ()=> LocalArticleBloc(sl(),sl(),sl())
  );

  sl.registerFactory<PublishArticleCubit>(
    ()=> PublishArticleCubit(sl(),sl())
  );


}