import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/firebase_auth_data_source.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_anonymous.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/repository/firebase_article_repository.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/data/data_sources/firestore_article_data_source.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/data/data_sources/storage_data_source.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/data/repository/firebase_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/use_cases/get_firebase_articles.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/use_cases/create_article.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/use_cases/delete_firebase_article.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_cubit.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/data/data_sources/ai_article_data_source.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/use_cases/generate_article_content.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Firebase
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  // --- Daily News Feature ---

  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(), sl()),
  );

  sl.registerSingleton<GetArticleUseCase>(
    GetArticleUseCase(sl()),
  );

  sl.registerSingleton<GetSavedArticleUseCase>(
    GetSavedArticleUseCase(sl()),
  );

  sl.registerSingleton<SaveArticleUseCase>(
    SaveArticleUseCase(sl()),
  );

  sl.registerSingleton<RemoveArticleUseCase>(
    RemoveArticleUseCase(sl()),
  );

  sl.registerFactory<RemoteArticlesBloc>(
    () => RemoteArticlesBloc(sl()),
  );

  sl.registerFactory<LocalArticleBloc>(
    () => LocalArticleBloc(sl(), sl(), sl()),
  );

  // --- Auth Feature ---

  sl.registerSingleton<FirebaseAuthDataSource>(
    FirebaseAuthDataSource(sl(), sl()),
  );

  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl()),
  );

  sl.registerSingleton<SignInUseCase>(
    SignInUseCase(sl()),
  );

  sl.registerSingleton<SignUpUseCase>(
    SignUpUseCase(sl()),
  );

  sl.registerSingleton<SignInAnonymousUseCase>(
    SignInAnonymousUseCase(sl()),
  );

  sl.registerSingleton<SignOutUseCase>(
    SignOutUseCase(sl()),
  );

  sl.registerSingleton<GetCurrentUserUseCase>(
    GetCurrentUserUseCase(sl()),
  );

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(sl(), sl(), sl(), sl(), sl()),
  );

  // --- Firebase Articles Feature ---

  sl.registerSingleton<FirestoreArticleDataSource>(
    FirestoreArticleDataSource(sl()),
  );

  sl.registerSingleton<StorageDataSource>(
    StorageDataSource(sl()),
  );

  sl.registerSingleton<AiArticleDataSource>(
    AiArticleDataSource(geminiApiKey),
  );

  sl.registerSingleton<FirebaseArticleRepository>(
    FirebaseArticleRepositoryImpl(sl(), sl(), sl()),
  );

  sl.registerSingleton<GetFirebaseArticlesUseCase>(
    GetFirebaseArticlesUseCase(sl()),
  );

  sl.registerSingleton<CreateArticleUseCase>(
    CreateArticleUseCase(sl()),
  );

  sl.registerSingleton<DeleteFirebaseArticleUseCase>(
    DeleteFirebaseArticleUseCase(sl()),
  );

  sl.registerSingleton<GenerateArticleContentUseCase>(
    GenerateArticleContentUseCase(sl()),
  );

  sl.registerFactory<FirebaseArticlesCubit>(
    () => FirebaseArticlesCubit(sl(), sl(), sl(), sl(), sl()),
  );
}
