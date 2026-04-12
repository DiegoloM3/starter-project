import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_article_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/local_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/remote_news_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_firestore_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';

import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'features/daily_news/presentation/bloc/user_profile/user_profile_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final database =
      await $FroomAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  // Dio
  sl.registerSingleton<Dio>(Dio(BaseOptions(baseUrl: newsAPIBaseURL)));

  // Data Sources
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<FirestoreArticleService>(
    FirestoreArticleService(
      FirebaseFirestore.instance,
      FirebaseStorage.instance,
    ),
  );

  // Repository (single impl, registered under each segregated interface)
  final articleRepository = ArticleRepositoryImpl(sl(), sl(), sl());
  sl.registerSingleton<RemoteNewsRepository>(articleRepository);
  sl.registerSingleton<LocalArticleRepository>(articleRepository);
  sl.registerSingleton<FirestoreArticleRepository>(articleRepository);

  // Use Cases
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));

  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));

  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  sl.registerSingleton<GetFirestoreArticlesUseCase>(
    GetFirestoreArticlesUseCase(sl()),
  );

  sl.registerSingleton<CreateArticleUseCase>(CreateArticleUseCase(sl()));

  sl.registerSingleton<UpdateArticleUseCase>(UpdateArticleUseCase(sl()));

  sl.registerSingleton<DeleteArticleUseCase>(DeleteArticleUseCase(sl()));

  // Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));

  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));

  sl.registerFactory<FirestoreArticlesBloc>(
      () => FirestoreArticlesBloc(sl()));

  sl.registerLazySingleton<UserProfileCubit>(() => UserProfileCubit());
}
