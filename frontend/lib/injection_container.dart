import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/domain/usecases/save_local_article.dart';
import 'features/daily_news/domain/usecases/delete_my_article.dart';
import 'features/daily_news/domain/usecases/upload_article_image.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'features/auth/data/data_sources/firebase_auth_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/daily_news/presentation/bloc/article/create/create_article_cubit.dart';
import 'features/daily_news/data/data_sources/remote/article_images_storage_data_source.dart';
import 'features/daily_news/data/data_sources/remote/articles_firestore_data_source.dart';
import 'features/daily_news/domain/usecases/get_my_articles.dart';
import 'features/daily_news/presentation/bloc/article/my/my_articles_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);
  sl.registerSingleton<ArticleDao>(database.articleDAO);
  
  // Firebase Auth
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseAuthDataSource>(
    FirebaseAuthDataSource(sl()),
  );

  // Firestore
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<ArticlesFirestoreDataSource>(
    ArticlesFirestoreDataSource(sl()),
  );

  // Storage
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  sl.registerSingleton<ArticleImagesStorageDataSource>(
    ArticleImagesStorageDataSource(sl()),
  );

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(
    NewsApiService(sl(), baseUrl: newsAPIBaseURL),
  );

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(), sl(), sl(), sl())
  );

  // Auth
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl()),
  );
  sl.registerSingleton<GetCurrentUserUseCase>(
    GetCurrentUserUseCase(sl()),
  );
  sl.registerSingleton<SignInUseCase>(
    SignInUseCase(sl()),
  );
  sl.registerSingleton<SignOutUseCase>(
    SignOutUseCase(sl()),
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
  sl.registerSingleton<SaveLocalArticleUseCase>(
    SaveLocalArticleUseCase(sl()),
  );
  
  sl.registerSingleton<RemoveArticleUseCase>(
    RemoveArticleUseCase(sl())
  );
  sl.registerSingleton<DeleteMyArticleUseCase>(
    DeleteMyArticleUseCase(sl()),
  );

  sl.registerSingleton<GetMyArticlesUseCase>(
    GetMyArticlesUseCase(sl()),
  );
  sl.registerSingleton<UploadArticleImageUseCase>(
    UploadArticleImageUseCase(sl()),
  );


  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl())
  );

  sl.registerFactory<LocalArticleBloc>(
    ()=> LocalArticleBloc(sl(),sl(),sl())
  );

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(sl(), sl(), sl()),
  );

  sl.registerFactory<CreateArticleCubit>(
    () => CreateArticleCubit(sl(), sl(), sl()),
  );

  sl.registerFactory<MyArticlesCubit>(
    () => MyArticlesCubit(sl(), sl(), sl()),
  );


}
