import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/comments/data/data_sources/firestore_comment_data_source.dart';
import 'package:news_app_clean_architecture/features/comments/data/repository/comment_repository_impl.dart';
import 'package:news_app_clean_architecture/features/comments/domain/repository/comment_repository.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/add_comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/watch_comments.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/bloc/comments_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/upload_article/data/data_sources/firestore_article_data_source.dart';
import 'package:news_app_clean_architecture/features/upload_article/data/data_sources/storage_article_data_source.dart';
import 'package:news_app_clean_architecture/features/upload_article/data/repository/user_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/list_user_articles.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/refresh_author_snapshots.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/upload_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/upload_article_cubit.dart';
import 'package:news_app_clean_architecture/shared/auth/data/data_sources/avatar_storage_data_source.dart';
import 'package:news_app_clean_architecture/shared/auth/data/data_sources/firebase_auth_data_source.dart';
import 'package:news_app_clean_architecture/shared/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/sign_up.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/update_display_name.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/update_password.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/update_profile_photo.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/watch_auth_state.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/bloc/profile_cubit.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/bloc/session_cubit.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  if (!kIsWeb) {
    final database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    sl.registerSingleton<AppDatabase>(database);
  }

  sl.registerSingleton<Dio>(Dio());
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));
  sl.registerSingleton<NewsApiDataSource>(NewsApiDataSource(sl()));

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(
        sl(), sl.isRegistered<AppDatabase>() ? sl<AppDatabase>() : null),
  );

  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));
  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));
  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));

  if (!kIsWeb) {
    sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(LocalArticleDeps(
        getSaved: sl(),
        save: sl(),
        remove: sl(),
      )),
    );
  }

  // Firebase core providers — injected ONLY into data_sources below.
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  // Auth
  sl.registerSingleton<FirebaseAuthDataSource>(FirebaseAuthDataSource(sl()));
  sl.registerSingleton<AvatarStorageDataSource>(
      AvatarStorageDataSource(sl(), sl()));
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl(), sl()));
  sl.registerSingleton<SignInUseCase>(SignInUseCase(sl()));
  sl.registerSingleton<SignUpUseCase>(SignUpUseCase(sl()));
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl()));
  sl.registerSingleton<WatchAuthStateUseCase>(WatchAuthStateUseCase(sl()));
  sl.registerSingleton<UpdateDisplayNameUseCase>(
      UpdateDisplayNameUseCase(sl()));
  sl.registerSingleton<UpdatePasswordUseCase>(UpdatePasswordUseCase(sl()));
  sl.registerSingleton<UpdateProfilePhotoUseCase>(
      UpdateProfilePhotoUseCase(sl()));
  sl.registerLazySingleton<SessionCubit>(() => SessionCubit(SessionDeps(
        signIn: sl(),
        signUp: sl(),
        signOut: sl(),
        watchAuthState: sl(),
      )));
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(ProfileDeps(
        updateDisplayName: sl(),
        updatePassword: sl(),
        updateProfilePhoto: sl(),
        refreshAuthorSnapshots: sl(),
      )));

  // Upload article
  sl.registerSingleton<FirestoreArticleDataSource>(
      FirestoreArticleDataSource(sl(), sl()));
  sl.registerSingleton<StorageArticleDataSource>(
      StorageArticleDataSource(sl(), sl()));
  sl.registerSingleton<UserArticleRepository>(
      UserArticleRepositoryImpl(UserArticleRepositoryDeps(
    firestore: sl(),
    storage: sl(),
  )));
  sl.registerSingleton<UploadArticleUseCase>(UploadArticleUseCase(sl()));
  sl.registerSingleton<UpdateArticleUseCase>(UpdateArticleUseCase(sl()));
  sl.registerSingleton<ListUserArticlesUseCase>(ListUserArticlesUseCase(sl()));
  sl.registerSingleton<DeleteArticleUseCase>(DeleteArticleUseCase(sl()));
  sl.registerSingleton<RefreshAuthorSnapshotsUseCase>(
      RefreshAuthorSnapshotsUseCase(sl()));
  sl.registerFactory<UploadArticleCubit>(() => UploadArticleCubit(sl(), sl()));
  sl.registerFactory<MyArticlesCubit>(() => MyArticlesCubit(MyArticlesDeps(
        list: sl(),
        delete: sl(),
      )));

  // Comments
  sl.registerSingleton<FirestoreCommentDataSource>(
      FirestoreCommentDataSource(sl(), sl()));
  sl.registerSingleton<CommentRepository>(CommentRepositoryImpl(sl()));
  sl.registerSingleton<AddCommentUseCase>(AddCommentUseCase(sl()));
  sl.registerSingleton<WatchCommentsUseCase>(WatchCommentsUseCase(sl()));
  sl.registerSingleton<DeleteCommentUseCase>(DeleteCommentUseCase(sl()));
  sl.registerFactory<CommentsCubit>(() => CommentsCubit(CommentsDeps(
        addComment: sl(),
        watchComments: sl(),
        deleteComment: sl(),
      )));
}
