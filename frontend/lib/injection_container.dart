import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app_clean_architecture/firebase_options.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/local/draft_dao.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/local/image_processing_service.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/local/image_processing_service_impl.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/remote/article_storage_service.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/remote/article_storage_service_impl.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/remote/articles_firestore_service.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/remote/articles_firestore_service_impl.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/repository/article_upload_repository_impl.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/delete_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/delete_draft.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/get_draft_by_id.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/save_draft.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/toggle_favorite.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/update_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_article_by_id.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_community_feed.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_drafts.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_favorite_ids.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_my_articles.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/my_articles/my_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/firebase_auth_service_impl.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/google_sign_in_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/google_sign_in_service_impl.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/user_document_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/user_document_service_impl.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/bootstrap_auth.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/link_anonymous_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/link_anonymous_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/send_password_reset.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_anonymously.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_articles_migration.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/saved_articles_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/saved_articles_service_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_fitness_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/use_cases/get_saved_article.dart';
import 'features/daily_news/domain/use_cases/is_article_saved.dart';
import 'features/daily_news/domain/use_cases/remove_article.dart';
import 'features/daily_news/domain/use_cases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/recommendations/data/data_sources/remote/recommendation_service.dart';
import 'package:news_app_clean_architecture/features/recommendations/data/data_sources/remote/recommendation_service_impl.dart';
import 'package:news_app_clean_architecture/features/recommendations/data/repository/recommendation_repository_impl.dart';
import 'package:news_app_clean_architecture/features/recommendations/domain/repository/recommendation_repository.dart';
import 'package:news_app_clean_architecture/features/recommendations/domain/use_cases/recommend_for_user.dart';
import 'package:news_app_clean_architecture/features/search/domain/use_cases/semantic_search.dart';
import 'package:news_app_clean_architecture/features/search/domain/repository/search_repository.dart';
import 'package:news_app_clean_architecture/features/search/data/repository/search_repository_impl.dart';
import 'package:news_app_clean_architecture/features/search/data/data_sources/remote/article_search_service.dart';
import 'package:news_app_clean_architecture/features/search/data/data_sources/remote/article_search_service_impl.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/locale_preferences_service.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/locale_preferences_service_impl.dart';
import 'package:news_app_clean_architecture/features/settings/data/repository/settings_repository_impl.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/get_locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/set_locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/locale/locale_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  final database = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .addMigrations([migration1to2])
      .build();
  sl.registerSingleton<AppDatabase>(database);

  // Firebase singletons — registered after Firebase.initializeApp() in main.dart
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerLazySingleton<SavedArticlesService>(
    () => SavedArticlesServiceImpl(sl<FirebaseFirestore>()),
  );

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(
      sl<NewsApiService>(),
      sl<SavedArticlesService>(),
      sl<FirebaseAuth>(),
    ),
  );
  
  //UseCases
  sl.registerSingleton<GetArticleUseCase>(
    GetArticleUseCase(sl())
  );

  sl.registerSingleton<GetFitnessArticlesUseCase>(
    GetFitnessArticlesUseCase(sl())
  );

  sl.registerSingleton<GetSavedArticleUseCase>(
    GetSavedArticleUseCase(sl())
  );

  sl.registerSingleton<SaveArticleUseCase>(
    SaveArticleUseCase(sl())
  );
  
  sl.registerSingleton<RemoveArticleUseCase>(
    RemoveArticleUseCase(sl())
  );

  sl.registerSingleton<IsArticleSavedUseCase>(
    IsArticleSavedUseCase(sl())
  );


  //Blocs — daily_news (factory = per-screen state)
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl())
  );

  sl.registerFactory<LocalArticleBloc>(
    ()=> LocalArticleBloc(sl(),sl(),sl())
  );

  // -----------------------------------------------------------------------
  // Auth — services, repository, use cases, bloc
  // -----------------------------------------------------------------------

  // Auth services
  // iOS workaround: GoogleSignIn iOS SDK 8.0 (transitively pulled by
  // google_sign_in_ios 5.9.0) requires the OAuth clientId to be set
  // explicitly before signIn — auto-detection from GoogleService-Info.plist
  // was removed in 8.0 and the Flutter plugin doesn't bridge it. Without
  // this, GIDSignIn throws an NSException at GIDSignIn.m:575 and the app
  // hard-crashes (SIGABRT). Reading the value from firebase_options.dart
  // keeps the binding tied to whatever flutterfire configure produced.
  // On Android the field is null, which is correct — Android resolves
  // the client via SHA-1 fingerprint + package name.
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      clientId: DefaultFirebaseOptions.currentPlatform.iosClientId,
      scopes: ['email'],
    ),
  );
  sl.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthServiceImpl(sl()),
  );
  sl.registerLazySingleton<GoogleSignInService>(
    () => GoogleSignInServiceImpl(sl()),
  );
  sl.registerLazySingleton<UserDocumentService>(
    () => UserDocumentServiceImpl(sl()),
  );

  // Auth repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl(), sl()),
  );

  // Auth use cases
  sl.registerLazySingleton<SignInAnonymouslyUseCase>(
    () => SignInAnonymouslyUseCase(sl()),
  );
  sl.registerLazySingleton<SignInWithEmailUseCase>(
    () => SignInWithEmailUseCase(sl()),
  );
  sl.registerLazySingleton<SignUpWithEmailUseCase>(
    () => SignUpWithEmailUseCase(sl()),
  );
  sl.registerLazySingleton<SignInWithGoogleUseCase>(
    () => SignInWithGoogleUseCase(sl()),
  );
  sl.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(sl()));
  sl.registerLazySingleton<SendPasswordResetUseCase>(
    () => SendPasswordResetUseCase(sl()),
  );
  sl.registerLazySingleton<WatchAuthStateUseCase>(
    () => WatchAuthStateUseCase(sl()),
  );
  sl.registerLazySingleton<BootstrapAuthUseCase>(
    () => BootstrapAuthUseCase(sl()),
  );
  sl.registerLazySingleton<LinkAnonymousWithEmailUseCase>(
    () => LinkAnonymousWithEmailUseCase(sl()),
  );
  sl.registerLazySingleton<LinkAnonymousWithGoogleUseCase>(
    () => LinkAnonymousWithGoogleUseCase(sl()),
  );

  // AuthBloc — lazySingleton (global state, NOT factory)
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );

  // -----------------------------------------------------------------------
  // Article upload — data-layer services and repository
  // Use cases and BLoCs are registered in Batch G.
  // -----------------------------------------------------------------------
  sl.registerLazySingleton<ArticlesFirestoreService>(
    () => ArticlesFirestoreServiceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ArticleStorageService>(
    () => ArticleStorageServiceImpl(sl<FirebaseStorage>()),
  );
  sl.registerLazySingleton<ImageProcessingService>(
    () => ImageProcessingServiceImpl(),
  );
  sl.registerLazySingleton<DraftDao>(
    () => sl<AppDatabase>().draftDao,
  );
  sl.registerLazySingleton<ArticleUploadRepository>(
    () => ArticleUploadRepositoryImpl(
      sl<ArticlesFirestoreService>(),
      sl<ArticleStorageService>(),
      sl<DraftDao>(),
      sl<FirebaseAuth>(),
    ),
  );

  // -----------------------------------------------------------------------
  // Article upload — use cases
  // -----------------------------------------------------------------------
  sl.registerLazySingleton<PublishArticleUseCase>(
    () => PublishArticleUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateArticleUseCase>(
    () => UpdateArticleUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteArticleUseCase>(
    () => DeleteArticleUseCase(sl()),
  );
  sl.registerLazySingleton<WatchMyArticlesUseCase>(
    () => WatchMyArticlesUseCase(sl()),
  );
  sl.registerLazySingleton<WatchCommunityFeedUseCase>(
    () => WatchCommunityFeedUseCase(sl()),
  );
  sl.registerLazySingleton<WatchArticleByIdUseCase>(
    () => WatchArticleByIdUseCase(sl()),
  );
  sl.registerLazySingleton<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(sl()),
  );
  sl.registerLazySingleton<WatchFavoriteIdsUseCase>(
    () => WatchFavoriteIdsUseCase(sl()),
  );
  sl.registerLazySingleton<SaveDraftUseCase>(
    () => SaveDraftUseCase(sl()),
  );
  sl.registerLazySingleton<WatchDraftsUseCase>(
    () => WatchDraftsUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteDraftUseCase>(
    () => DeleteDraftUseCase(sl()),
  );
  sl.registerLazySingleton<GetDraftByIdUseCase>(
    () => GetDraftByIdUseCase(sl()),
  );

  // -----------------------------------------------------------------------
  // Article upload — BLoCs
  // -----------------------------------------------------------------------
  sl.registerFactory<UploadArticleBloc>(
    () => UploadArticleBloc(
      sl<PublishArticleUseCase>(),
      sl<SaveDraftUseCase>(),
      sl<ImageProcessingService>(),
      sl<FirebaseAuth>(),
      sl<GetDraftByIdUseCase>(),
      sl<UpdateArticleUseCase>(),
    ),
  );

  sl.registerLazySingleton<FirebaseFunctions>(
    () => FirebaseFunctions.instance,
  );

  sl.registerLazySingleton<ArticleSearchService>(
    () => ArticleSearchServiceImpl(sl<FirebaseFunctions>()),
  );

  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(sl<ArticleSearchService>()),
  );

  sl.registerLazySingleton<SemanticSearchUseCase>(
    () => SemanticSearchUseCase(sl<SearchRepository>()),
  );

  sl.registerLazySingleton<RecommendationService>(
    () => RecommendationServiceImpl(sl<FirebaseFunctions>()),
  );
  sl.registerLazySingleton<RecommendationRepository>(
    () => RecommendationRepositoryImpl(sl<RecommendationService>()),
  );
  sl.registerLazySingleton<RecommendForUserUseCase>(
    () => RecommendForUserUseCase(sl<RecommendationRepository>()),
  );

  sl.registerLazySingleton<FeedBloc>(
    () => FeedBloc(
      sl<GetArticleUseCase>(),
      sl<GetFitnessArticlesUseCase>(),
      sl<WatchCommunityFeedUseCase>(),
      sl<SemanticSearchUseCase>(),
      sl<RecommendForUserUseCase>(),
    ),
  );

  sl.registerFactory<MyArticlesBloc>(
    () => MyArticlesBloc(
      sl<WatchMyArticlesUseCase>(),
      sl<DeleteArticleUseCase>(),
      sl<WatchDraftsUseCase>(),
      sl<DeleteDraftUseCase>(),
    ),
  );

  sl.registerLazySingleton<FavoritesBloc>(
    () => FavoritesBloc(
      sl<WatchFavoriteIdsUseCase>(),
      sl<ToggleFavoriteUseCase>(),
      sl<FirebaseAuth>(),
    ),
  );

  // -----------------------------------------------------------------------
  // Settings — locale preferences (per-device, SharedPreferences)
  // -----------------------------------------------------------------------
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPrefs);

  sl.registerLazySingleton<LocalePreferencesService>(
    () => LocalePreferencesServiceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl<LocalePreferencesService>()),
  );
  sl.registerLazySingleton<GetLocalePreferenceUseCase>(
    () => GetLocalePreferenceUseCase(sl<SettingsRepository>()),
  );
  sl.registerLazySingleton<SetLocalePreferenceUseCase>(
    () => SetLocalePreferenceUseCase(sl<SettingsRepository>()),
  );
  sl.registerLazySingleton<LocaleBloc>(
    () => LocaleBloc(
      sl<GetLocalePreferenceUseCase>(),
      sl<SetLocalePreferenceUseCase>(),
    ),
  );

  sl.registerLazySingleton<SavedArticlesMigration>(
    () => SavedArticlesMigration(
      sl<AppDatabase>().articleDAO,
      sl<SavedArticlesService>(),
      sl<FirebaseAuth>(),
      sl<SharedPreferences>(),
    ),
  );
}