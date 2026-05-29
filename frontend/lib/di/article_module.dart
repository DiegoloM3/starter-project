import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firebase_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_article_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_draft_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_published_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_user_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/search_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_feed_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/drafts/drafts_list_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/feed/feed_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/published/published_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/action/article_action_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/search/search_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/user/user_articles_bloc.dart';

void registerArticleModule(GetIt sl) {
  // Data Sources
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));
  sl.registerSingleton<FirestoreArticleDataSource>(
      FirestoreArticleDataSource(sl()));
  sl.registerSingleton<FirebaseStorageDataSource>(
      FirebaseStorageDataSource(sl()));

  // Repository
  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(
      sl(),
      sl(),
      sl(),
      sl(),
      sl<AuthRepository>(),
    ),
  );

  // Use Cases
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));
  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));
  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));
  sl.registerSingleton<CreateArticleUseCase>(CreateArticleUseCase(sl()));
  sl.registerSingleton<UpdateArticleUseCase>(UpdateArticleUseCase(sl()));
  sl.registerSingleton<DeleteArticleUseCase>(DeleteArticleUseCase(sl()));
  sl.registerSingleton<GetPublishedArticlesUseCase>(
      GetPublishedArticlesUseCase(sl()));
  sl.registerSingleton<GetUserArticlesUseCase>(GetUserArticlesUseCase(sl()));
  sl.registerSingleton<GetDraftArticlesUseCase>(GetDraftArticlesUseCase(sl()));
  sl.registerSingleton<UploadThumbnailUseCase>(UploadThumbnailUseCase(sl()));
  sl.registerSingleton<SearchArticlesUseCase>(SearchArticlesUseCase(sl()));
  sl.registerSingleton<GetFeedArticlesUseCase>(GetFeedArticlesUseCase(sl()));

  // BLoCs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));
  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));
  sl.registerFactory<CreateArticleBloc>(() {
    final user = sl<AuthRepository>().currentUser;
    return CreateArticleBloc(
      sl(),
      sl(),
      sl(),
      authorId: user?.uid ?? '',
      authorName: user?.displayName ?? 'Anonymous',
    );
  });
  sl.registerFactory<DraftsListBloc>(() => DraftsListBloc(sl(), sl()));
  sl.registerFactory<PublishedArticlesBloc>(
      () => PublishedArticlesBloc(sl()));
  sl.registerFactory<FeedBloc>(() => FeedBloc(sl()));
  sl.registerFactory<SearchArticlesBloc>(
      () => SearchArticlesBloc(sl<GetFeedArticlesUseCase>()));
  sl.registerFactory<UserArticlesBloc>(
      () => UserArticlesBloc(sl(), sl()));
  sl.registerFactory<ArticleActionCubit>(
      () => ArticleActionCubit(sl()));
}
