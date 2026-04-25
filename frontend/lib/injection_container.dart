import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_google_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
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
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/articles/data/datasources/remote/article_remote_data_source.dart'
    as art_ds;
import 'package:news_app_clean_architecture/features/articles/data/repositories/article_repository_impl.dart'
    as art_impl;
import 'package:news_app_clean_architecture/features/articles/domain/repositories/article_repository.dart'
    as art_repo;
import 'package:news_app_clean_architecture/features/articles/domain/usecases/create_article_use_case.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/delete_article_use_case.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_article_by_id_use_case.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles_use_case.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_my_articles_use_case.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/update_article_use_case.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/articles_cubit.dart';

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

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));

  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));

  // Firebase
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  sl.registerSingleton<GoogleSignIn>(GoogleSignIn());

  // Auth data sources
  sl.registerSingleton<AuthRemoteDataSource>(
      AuthRemoteDataSourceImpl(sl(), sl(), sl()));

  // Auth repository
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl()));

  // Auth use cases
  sl.registerSingleton<SignInUseCase>(SignInUseCase(sl()));
  sl.registerSingleton<SignUpUseCase>(SignUpUseCase(sl()));
  sl.registerSingleton<SignInWithGoogleUseCase>(SignInWithGoogleUseCase(sl()));
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl()));
  sl.registerSingleton<GetCurrentUserUseCase>(GetCurrentUserUseCase(sl()));
  sl.registerSingleton<ForgotPasswordUseCase>(ForgotPasswordUseCase(sl()));

  // Auth cubit
  sl.registerFactory<AuthCubit>(
      () => AuthCubit(sl(), sl(), sl(), sl(), sl(), sl()));

  // Articles data source
  sl.registerSingleton<art_ds.ArticleRemoteDataSource>(
      art_ds.ArticleRemoteDataSourceImpl(sl(), sl(), sl()));

  // Articles repository
  sl.registerSingleton<art_repo.ArticleRepository>(
      art_impl.ArticleRepositoryImpl(sl()));

  // Articles use cases
  sl.registerSingleton<GetArticlesUseCase>(
      GetArticlesUseCase(sl<art_repo.ArticleRepository>()));
  sl.registerSingleton<GetMyArticlesUseCase>(
      GetMyArticlesUseCase(sl<art_repo.ArticleRepository>()));
  sl.registerSingleton<GetArticleByIdUseCase>(
      GetArticleByIdUseCase(sl<art_repo.ArticleRepository>()));
  sl.registerSingleton<CreateArticleUseCase>(
      CreateArticleUseCase(sl<art_repo.ArticleRepository>()));
  sl.registerSingleton<UpdateArticleUseCase>(
      UpdateArticleUseCase(sl<art_repo.ArticleRepository>()));
  sl.registerSingleton<DeleteArticleUseCase>(
      DeleteArticleUseCase(sl<art_repo.ArticleRepository>()));

  // Articles cubit
  sl.registerFactory<ArticlesCubit>(
      () => ArticlesCubit(sl(), sl(), sl(), sl(), sl()));
}
