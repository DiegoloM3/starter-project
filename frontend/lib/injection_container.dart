import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/core/session/auth_session.dart';
import 'package:news_app_clean_architecture/core/session/firebase_auth_session.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/user_articles_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/user_articles_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/fake/fake_user_article_repository.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/repository/user_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/publish_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/upload_thumbnail.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/services/thumbnail_picker_service.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final database = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .build();

  sl
    ..registerSingleton<AppDatabase>(database)
    ..registerSingleton<Dio>(Dio())
    ..registerSingleton<NewsApiService>(NewsApiService(sl()))
    ..registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl()))
    ..registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()))
    ..registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()))
    ..registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()))
    ..registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()))
    ..registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()))
    ..registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()),
    );

  _registerUserArticles();
}

/// Wires the user_articles feature.
///
/// When `Firebase.initializeApp` has already run (F0 unblocked), the real
/// Firestore-backed repository is registered. Otherwise the in-memory
/// fake keeps the app runnable in development and under tests.
void _registerUserArticles() {
  if (Firebase.apps.isNotEmpty) {
    final firebaseAuthSession = FirebaseAuthSession(FirebaseAuth.instance);
    sl
      ..registerSingleton<FirebaseAuthSession>(firebaseAuthSession)
      ..registerSingleton<AuthSession>(firebaseAuthSession);
  } else {
    sl.registerSingleton<AuthSession>(DevAuthSession());
  }

  if (Firebase.apps.isNotEmpty) {
    sl
      ..registerSingleton<UserArticlesFirestoreDataSource>(
        UserArticlesFirestoreDataSource(FirebaseFirestore.instance),
      )
      ..registerSingleton<UserArticlesStorageDataSource>(
        UserArticlesStorageDataSource(FirebaseStorage.instance),
      )
      ..registerSingleton<UserArticleRepository>(
        UserArticleRepositoryImpl(sl(), sl()),
      );
  } else {
    sl.registerSingleton<UserArticleRepository>(FakeUserArticleRepository());
  }

  sl
    ..registerSingleton<ThumbnailPickerService>(
      Firebase.apps.isNotEmpty
          ? GalleryThumbnailPickerService()
          : const StubThumbnailPickerService(),
    )
    ..registerSingleton<GetMyArticlesUseCase>(GetMyArticlesUseCase(sl()))
    ..registerSingleton<PublishArticleUseCase>(PublishArticleUseCase(sl()))
    ..registerSingleton<UpdateArticleUseCase>(UpdateArticleUseCase(sl()))
    ..registerSingleton<DeleteArticleUseCase>(DeleteArticleUseCase(sl()))
    ..registerSingleton<UploadThumbnailUseCase>(UploadThumbnailUseCase(sl()))
    ..registerFactory<MyArticlesCubit>(
      () => MyArticlesCubit(
        getMyArticles: sl(),
        deleteArticle: sl(),
      ),
    );
}
