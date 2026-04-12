import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/data_sources/local/articles_local_database.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/data_sources/remote/articles_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/data_sources/remote/articles_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/data_sources/remote/auth_session.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/repository/articles_upload_repository_impl.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/repository/articles_upload_repository.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/repository/auth_service.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/get_all_articles.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/load_next_page.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/sync_articles.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/articles_list/articles_list_bloc.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/create_article/create_article_cubit.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/create_article/edit_article_cubit.dart';

Future<void> registerArticlesUploadModule(GetIt sl) async {
  final articlesLocalDb = await $FloorArticlesLocalDatabase
      .databaseBuilder('articles_local.db')
      .build();
  sl.registerSingleton<ArticlesLocalDatabase>(articlesLocalDb);

  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  }
  if (!sl.isRegistered<FirebaseStorage>()) {
    sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  }
  if (!sl.isRegistered<FirebaseAuth>()) {
    sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  }

  sl.registerSingleton<ArticlesFirestoreDataSource>(
    ArticlesFirestoreDataSource(sl()),
  );
  sl.registerSingleton<ArticlesStorageDataSource>(
    ArticlesStorageDataSource(sl()),
  );
  final authSession = AuthSession(sl());
  sl.registerSingleton<AuthSession>(authSession);
  sl.registerSingleton<AuthService>(authSession);

  final repoImpl = ArticlesUploadRepositoryImpl(
    sl(),
    sl(),
    sl(),
    articlesLocalDb.articleUploadDao,
  );
  sl.registerSingleton<ArticlesUploadRepository>(repoImpl);

  sl.registerSingleton<GetAllArticlesUseCase>(GetAllArticlesUseCase(sl()));
  sl.registerSingleton<CreateArticleUseCase>(CreateArticleUseCase(sl()));
  sl.registerSingleton<DeleteArticleUseCase>(DeleteArticleUseCase(sl()));
  sl.registerSingleton<UpdateArticleUseCase>(UpdateArticleUseCase(sl()));
  sl.registerSingleton<SyncArticlesUseCase>(SyncArticlesUseCase(sl()));
  sl.registerSingleton<LoadNextPageUseCase>(LoadNextPageUseCase(sl()));

  sl.registerFactory<ArticlesListBloc>(
    () => ArticlesListBloc(
      sl(),
      sl(),
      syncArticles: sl<SyncArticlesUseCase>(),
      loadNextPage: sl<LoadNextPageUseCase>(),
      pageSize: sl<ArticlesUploadRepository>().pageSize,
    ),
  );
  sl.registerFactory<CreateArticleCubit>(() => CreateArticleCubit(sl()));
  sl.registerFactory<EditArticleCubit>(() => EditArticleCubit(sl()));
}
