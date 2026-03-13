import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Core
import 'core/services/secure_storage_service.dart';
import 'config/theme/theme_cubit.dart';

// Daily News Feature
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

// Auth Feature
import 'features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/get_auth_state_changes.dart';
import 'features/auth/domain/usecases/change_password.dart';
import 'features/auth/domain/usecases/forgot_password.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// User Articles Feature
import 'features/user_articles/data/data_sources/remote/article_remote_data_source.dart';
import 'features/user_articles/data/data_sources/remote/cloudinary_service.dart';
import 'features/user_articles/data/repository/user_article_repository_impl.dart';
import 'features/user_articles/domain/repository/user_article_repository.dart';
import 'features/user_articles/domain/usecases/create_article.dart';
import 'features/user_articles/domain/usecases/update_article.dart';
import 'features/user_articles/domain/usecases/delete_article.dart';
import 'features/user_articles/domain/usecases/get_user_articles.dart';
import 'features/user_articles/domain/usecases/get_published_articles.dart';
import 'features/user_articles/domain/usecases/get_articles_by_category.dart';
import 'features/user_articles/domain/usecases/publish_article.dart';
import 'features/user_articles/domain/usecases/upload_image.dart';
import 'features/user_articles/presentation/bloc/user_articles/user_articles_bloc.dart';
import 'features/user_articles/presentation/bloc/article_editor/article_editor_cubit.dart';
import 'features/user_articles/presentation/bloc/article_detail/tts_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ==================== Core ====================
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Secure Storage
  sl.registerSingleton<SecureStorageService>(SecureStorageServiceImpl());

  // Theme
  sl.registerFactory<ThemeCubit>(
      () => ThemeCubit(storageService: sl<SecureStorageService>()));

  // ==================== Daily News Feature ====================
  // Data Sources
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  // Repository
  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl()));

  // Use Cases
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));

  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));

  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  // Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));

  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));

  // ==================== Auth Feature ====================
  // Data Sources
  sl.registerSingleton<AuthRemoteDataSource>(AuthRemoteDataSourceImpl());

  // Repository
  sl.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(sl<AuthRemoteDataSource>()));

  // Use Cases
  sl.registerSingleton<SignInUseCase>(SignInUseCase(sl<AuthRepository>()));

  sl.registerSingleton<SignUpUseCase>(SignUpUseCase(sl<AuthRepository>()));

  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl<AuthRepository>()));

  sl.registerSingleton<GetCurrentUserUseCase>(
      GetCurrentUserUseCase(sl<AuthRepository>()));

  sl.registerSingleton<GetAuthStateChangesUseCase>(
      GetAuthStateChangesUseCase(sl<AuthRepository>()));

  sl.registerSingleton<ChangePasswordUseCase>(
      ChangePasswordUseCase(sl<AuthRepository>()));

  sl.registerSingleton<ForgotPasswordUseCase>(
      ForgotPasswordUseCase(sl<AuthRepository>()));

  // Bloc
  sl.registerFactory<AuthBloc>(() => AuthBloc(
        signInUseCase: sl<SignInUseCase>(),
        signUpUseCase: sl<SignUpUseCase>(),
        signOutUseCase: sl<SignOutUseCase>(),
        getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
        getAuthStateChangesUseCase: sl<GetAuthStateChangesUseCase>(),
        changePasswordUseCase: sl<ChangePasswordUseCase>(),
        forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
      ));

  // ==================== User Articles Feature ====================
  // Data Sources
  sl.registerSingleton<ArticleRemoteDataSource>(ArticleRemoteDataSourceImpl());

  sl.registerSingleton<CloudinaryService>(
      CloudinaryServiceImpl.fromEnv(dio: sl<Dio>()));

  // Repository
  sl.registerSingleton<UserArticleRepository>(UserArticleRepositoryImpl(
    articleRemoteDataSource: sl<ArticleRemoteDataSource>(),
    cloudinaryService: sl<CloudinaryService>(),
  ));

  // Use Cases
  sl.registerSingleton<CreateArticleUseCase>(
      CreateArticleUseCase(sl<UserArticleRepository>()));

  sl.registerSingleton<UpdateArticleUseCase>(
      UpdateArticleUseCase(sl<UserArticleRepository>()));

  sl.registerSingleton<DeleteArticleUseCase>(
      DeleteArticleUseCase(sl<UserArticleRepository>()));

  sl.registerSingleton<GetUserArticlesUseCase>(
      GetUserArticlesUseCase(sl<UserArticleRepository>()));

  sl.registerSingleton<GetPublishedArticlesUseCase>(
      GetPublishedArticlesUseCase(sl<UserArticleRepository>()));

  sl.registerSingleton<GetArticlesByCategoryUseCase>(
      GetArticlesByCategoryUseCase(sl<UserArticleRepository>()));

  sl.registerSingleton<PublishArticleUseCase>(
      PublishArticleUseCase(sl<UserArticleRepository>()));

  sl.registerSingleton<UploadImageUseCase>(
      UploadImageUseCase(sl<UserArticleRepository>()));

  // Blocs/Cubits
  sl.registerFactory<UserArticlesBloc>(() => UserArticlesBloc(
        getUserArticlesUseCase: sl<GetUserArticlesUseCase>(),
        getPublishedArticlesUseCase: sl<GetPublishedArticlesUseCase>(),
        getArticlesByCategoryUseCase: sl<GetArticlesByCategoryUseCase>(),
        deleteArticleUseCase: sl<DeleteArticleUseCase>(),
        publishArticleUseCase: sl<PublishArticleUseCase>(),
      ));

  sl.registerFactory<ArticleEditorCubit>(() => ArticleEditorCubit(
        createArticleUseCase: sl<CreateArticleUseCase>(),
        updateArticleUseCase: sl<UpdateArticleUseCase>(),
        publishArticleUseCase: sl<PublishArticleUseCase>(),
        uploadImageUseCase: sl<UploadImageUseCase>(),
      ));

  sl.registerFactory<TtsCubit>(() => TtsCubit(flutterTts: FlutterTts()));
}
