import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_news_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/use_cases/register.dart';
import 'features/auth/domain/use_cases/sign_in.dart';
import 'features/auth/domain/use_cases/sign_out.dart';
import 'features/auth/domain/use_cases/watch_session.dart';
import 'features/auth/presentation/bloc/register/register_cubit.dart';
import 'features/auth/presentation/bloc/session/session_cubit.dart';
import 'features/auth/presentation/bloc/sign_in/sign_in_cubit.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/entities/article.dart';
import 'features/daily_news/domain/use_cases/get_saved_articles.dart';
import 'features/daily_news/domain/use_cases/is_article_saved.dart';
import 'features/daily_news/domain/use_cases/remove_article.dart';
import 'features/daily_news/domain/use_cases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/bookmark/article_bookmark_cubit.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'features/journalist_articles/data/data_sources/local/article_thumbnail_gallery_data_source.dart';
import 'features/journalist_articles/data/data_sources/remote/article_comment_remote_data_source.dart';
import 'features/journalist_articles/data/data_sources/remote/article_thumbnail_remote_data_source.dart';
import 'features/journalist_articles/data/data_sources/remote/journalist_article_remote_data_source.dart';
import 'features/journalist_articles/data/data_sources/remote/saved_journalist_article_remote_data_source.dart';
import 'features/journalist_articles/data/repository/article_comment_repository_impl.dart';
import 'features/journalist_articles/data/repository/article_thumbnail_repository_impl.dart';
import 'features/journalist_articles/data/repository/journalist_article_repository_impl.dart';
import 'features/journalist_articles/data/repository/saved_journalist_article_repository_impl.dart';
import 'features/journalist_articles/domain/repository/article_comment_repository.dart';
import 'features/journalist_articles/domain/repository/article_thumbnail_repository.dart';
import 'features/journalist_articles/domain/repository/journalist_article_repository.dart';
import 'features/journalist_articles/domain/repository/saved_journalist_article_repository.dart';
import 'features/journalist_articles/domain/use_cases/add_article_comment.dart';
import 'features/journalist_articles/domain/use_cases/get_article_comments.dart';
import 'features/journalist_articles/domain/use_cases/get_published_articles.dart';
import 'features/journalist_articles/domain/use_cases/get_saved_journalist_articles.dart';
import 'features/journalist_articles/domain/use_cases/is_journalist_article_saved.dart';
import 'features/journalist_articles/domain/use_cases/pick_article_thumbnail.dart';
import 'features/journalist_articles/domain/use_cases/publish_article.dart';
import 'features/journalist_articles/domain/use_cases/remove_saved_journalist_article.dart';
import 'features/journalist_articles/domain/use_cases/save_journalist_article.dart';
import 'features/journalist_articles/presentation/bloc/add_article_comment/add_article_comment_cubit.dart';
import 'features/journalist_articles/presentation/bloc/article_comments/article_comments_cubit.dart';
import 'features/journalist_articles/presentation/bloc/journalist_article_bookmark/journalist_article_bookmark_cubit.dart';
import 'features/journalist_articles/presentation/bloc/publish_article/publish_article_cubit.dart';
import 'features/journalist_articles/presentation/bloc/published_articles/published_articles_cubit.dart';
import 'features/journalist_articles/presentation/bloc/saved_journalist_articles/saved_journalist_articles_cubit.dart';
import 'features/settings/data/data_sources/local/settings_local_data_source.dart';
import 'features/settings/data/repository/settings_repository_impl.dart';
import 'features/settings/domain/repository/settings_repository.dart';
import 'features/settings/domain/use_cases/get_theme_preference.dart';
import 'features/settings/domain/use_cases/save_theme_preference.dart';
import 'features/settings/presentation/bloc/theme/theme_cubit.dart';
import 'firebase_emulators.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  await _initializeDailyNewsDependencies();
  // Before any Firebase request, so every feature talks to the same backend.
  await connectToFirebaseEmulatorsIfEnabled();
  _initializeAuthDependencies();
  _initializeJournalistArticlesDependencies();
  _initializeSettingsDependencies();
}

Future<void> _initializeDailyNewsDependencies() async {
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);
  sl.registerSingleton<Dio>(Dio());
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));
  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl()));

  sl.registerSingleton<GetNewsArticlesUseCase>(GetNewsArticlesUseCase(sl()));
  sl.registerSingleton<GetSavedArticlesUseCase>(GetSavedArticlesUseCase(sl()));
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));
  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));
  sl.registerSingleton<IsArticleSavedUseCase>(IsArticleSavedUseCase(sl()));

  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));
  sl.registerFactory<LocalArticlesBloc>(() => LocalArticlesBloc(sl(), sl()));
  // Created for each news article, which is its parameter.
  sl.registerFactoryParam<ArticleBookmarkCubit, ArticleEntity, void>(
    (article, _) => ArticleBookmarkCubit(sl(), sl(), sl(), article),
  );
}

void _initializeAuthDependencies() {
  sl.registerSingleton<AuthRemoteDataSource>(AuthRemoteDataSourceImpl());
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl()));
  sl.registerSingleton<WatchSessionUseCase>(WatchSessionUseCase(sl()));
  sl.registerSingleton<SignInUseCase>(SignInUseCase(sl()));
  sl.registerSingleton<RegisterUseCase>(RegisterUseCase(sl()));
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl()));
  // A single instance: the whole app follows the session it holds.
  sl.registerSingleton<SessionCubit>(SessionCubit(sl(), sl()));
  sl.registerFactory<SignInCubit>(() => SignInCubit(sl()));
  sl.registerFactory<RegisterCubit>(() => RegisterCubit(sl()));
}

void _initializeSettingsDependencies() {
  sl.registerSingleton<SettingsLocalDataSource>(SettingsLocalDataSourceImpl());
  sl.registerSingleton<SettingsRepository>(SettingsRepositoryImpl(sl()));
  sl.registerSingleton<GetThemePreferenceUseCase>(GetThemePreferenceUseCase(sl()));
  sl.registerSingleton<SaveThemePreferenceUseCase>(SaveThemePreferenceUseCase(sl()));
  // A single instance: the whole app is drawn with the theme it holds.
  sl.registerSingleton<ThemeCubit>(ThemeCubit(sl(), sl()));
}

void _initializeJournalistArticlesDependencies() {
  //Data sources
  sl.registerSingleton<JournalistArticleRemoteDataSource>(JournalistArticleRemoteDataSourceImpl());
  sl.registerSingleton<ArticleThumbnailRemoteDataSource>(ArticleThumbnailRemoteDataSourceImpl());
  sl.registerSingleton<ArticleThumbnailGalleryDataSource>(ArticleThumbnailGalleryDataSourceImpl());
  sl.registerSingleton<ArticleCommentRemoteDataSource>(ArticleCommentRemoteDataSourceImpl());
  sl.registerSingleton<SavedJournalistArticleRemoteDataSource>(SavedJournalistArticleRemoteDataSourceImpl());

  //Repositories
  sl.registerSingleton<JournalistArticleRepository>(JournalistArticleRepositoryImpl(sl(), sl()));
  sl.registerSingleton<ArticleThumbnailRepository>(ArticleThumbnailRepositoryImpl(sl()));
  sl.registerSingleton<ArticleCommentRepository>(ArticleCommentRepositoryImpl(sl()));
  sl.registerSingleton<SavedJournalistArticleRepository>(SavedJournalistArticleRepositoryImpl(sl(), sl()));

  //UseCases
  sl.registerSingleton<GetPublishedArticlesUseCase>(GetPublishedArticlesUseCase(sl()));
  sl.registerSingleton<PublishArticleUseCase>(PublishArticleUseCase(sl()));
  sl.registerSingleton<PickArticleThumbnailUseCase>(PickArticleThumbnailUseCase(sl()));
  sl.registerSingleton<GetArticleCommentsUseCase>(GetArticleCommentsUseCase(sl()));
  sl.registerSingleton<AddArticleCommentUseCase>(AddArticleCommentUseCase(sl()));
  sl.registerSingleton<GetSavedJournalistArticlesUseCase>(GetSavedJournalistArticlesUseCase(sl()));
  sl.registerSingleton<IsJournalistArticleSavedUseCase>(IsJournalistArticleSavedUseCase(sl()));
  sl.registerSingleton<SaveJournalistArticleUseCase>(SaveJournalistArticleUseCase(sl()));
  sl.registerSingleton<RemoveSavedJournalistArticleUseCase>(RemoveSavedJournalistArticleUseCase(sl()));

  //Cubits
  sl.registerFactory<PublishedArticlesCubit>(() => PublishedArticlesCubit(sl()));
  sl.registerFactory<PublishArticleCubit>(() => PublishArticleCubit(sl(), sl()));
  // Created for each article: their parameter is the ID of the article.
  sl.registerFactoryParam<ArticleCommentsCubit, String, void>((articleId, _) => ArticleCommentsCubit(sl(), articleId));
  sl.registerFactoryParam<AddArticleCommentCubit, String, void>(
    (articleId, _) => AddArticleCommentCubit(sl(), articleId),
  );
  sl.registerFactoryParam<JournalistArticleBookmarkCubit, String, void>(
    (articleId, _) => JournalistArticleBookmarkCubit(sl(), sl(), sl(), articleId),
  );
  sl.registerFactory<SavedJournalistArticlesCubit>(() => SavedJournalistArticlesCubit(sl(), sl()));
}