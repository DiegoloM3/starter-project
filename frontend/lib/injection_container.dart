import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';
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
import 'features/publish_article/domain/use_cases/publish_article_use_case.dart';
import 'features/publish_article/domain/repository/publish_article_repository.dart';
import 'features/publish_article/data/repository/publish_article_repository_impl.dart';
import 'features/publish_article/data/data_sources/article_firestore_data_source.dart';
import 'features/publish_article/data/data_sources/article_storage_data_source.dart';
import 'features/publish_article/data/data_sources/firebase_article_firestore_data_source.dart';
import 'features/publish_article/data/data_sources/firebase_article_storage_data_source.dart';
import 'features/publish_article/data/data_sources/firebase_published_articles_firestore_data_source.dart';
import 'features/publish_article/data/data_sources/published_articles_firestore_data_source.dart';
import 'features/publish_article/data/repository/read_published_articles_repository_impl.dart';
import 'features/publish_article/domain/repository/read_published_articles_repository.dart';
import 'features/publish_article/domain/use_cases/get_published_articles_use_case.dart';
import 'features/publish_article/presentation/cubit/publish_article_cubit.dart';
import 'features/publish_article/presentation/cubit/published_articles_cubit.dart';
import 'features/publish_article/domain/repository/article_image_picker.dart';
import 'features/publish_article/data/data_sources/gallery_article_image_data_source.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl()));

  //UseCases
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));

  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));

  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  registerPublicationDependencies(sl);

  sl.registerLazySingleton<ArticleImagePicker>(
    () => GalleryArticleImagePicker(),
  );

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));

  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));

  sl.registerFactory<PublishArticleCubit>(
    () => PublishArticleCubit(sl()),
  );

  sl.registerFactory<PublishedArticlesCubit>(
    () => PublishedArticlesCubit(sl()),
  );
}

/// Separate composition entry point so publication can be tested without Floor.
void registerPublicationDependencies(GetIt container) {
  container.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);
  container
      .registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  container.registerLazySingleton<ArticleFirestoreDataSource>(
    () => FirebaseArticleFirestoreDataSource(container<FirebaseFirestore>()),
  );
  container.registerLazySingleton<ArticleStorageDataSource>(
    () => FirebaseArticleStorageDataSource(container<FirebaseStorage>()),
  );
  // Session lifetime is required to retain unresolved publication attempts.
  container.registerLazySingleton<PublishArticleRepository>(
    () => PublishArticleRepositoryImpl(container(), container()),
  );
  container.registerLazySingleton<PublishArticleUseCase>(
    () => PublishArticleUseCase(container()),
  );
  container.registerLazySingleton<PublishedArticlesFirestoreDataSource>(
    () => FirebasePublishedArticlesFirestoreDataSource(
      container<FirebaseFirestore>(),
    ),
  );
  container.registerLazySingleton<ReadPublishedArticlesRepository>(
    () => ReadPublishedArticlesRepositoryImpl(container()),
  );
  container.registerLazySingleton<GetPublishedArticlesUseCase>(
    () => GetPublishedArticlesUseCase(container()),
  );
}
