import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/core/session/auth_session.dart';
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
import 'package:news_app_clean_architecture/features/user_articles/data/fake/fake_user_article_repository.dart';
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
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(), sl()),
  );

  //UseCases
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));
  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));
  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));
  sl.registerFactory<LocalArticleBloc>(
    () => LocalArticleBloc(sl(), sl(), sl()),
  );

  _registerUserArticles();
}

/// Wires the user_articles feature. F8 replaces the Fake binding with the
/// real Firestore/Storage implementation by swapping *only* the
/// [UserArticleRepository] registration below — every use case and bloc
/// keeps its existing wiring.
void _registerUserArticles() {
  sl.registerSingleton<AuthSession>(const DevAuthSession());

  // Fake repository until F8 wires Firestore. Kept behind the
  // `UserArticleRepository` port so use cases stay agnostic.
  sl.registerSingleton<UserArticleRepository>(FakeUserArticleRepository());

  sl.registerSingleton<ThumbnailPickerService>(
    const StubThumbnailPickerService(),
  );

  sl.registerSingleton<GetMyArticlesUseCase>(GetMyArticlesUseCase(sl()));
  sl.registerSingleton<PublishArticleUseCase>(PublishArticleUseCase(sl()));
  sl.registerSingleton<UpdateArticleUseCase>(UpdateArticleUseCase(sl()));
  sl.registerSingleton<DeleteArticleUseCase>(DeleteArticleUseCase(sl()));
  sl.registerSingleton<UploadThumbnailUseCase>(UploadThumbnailUseCase(sl()));

  sl.registerFactory<MyArticlesCubit>(
    () => MyArticlesCubit(
      getMyArticles: sl(),
      deleteArticle: sl(),
    ),
  );
}
