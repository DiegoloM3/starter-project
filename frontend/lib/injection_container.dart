// coverage:ignore-file
// Composition root: wires SDK instances that only exist on a device.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/profile_photo_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/profile_photo_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/update_profile.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/edit_profile/edit_profile_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_in/sign_in_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_up/sign_up_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_firestore_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/assistant_functions_service.dart';
import 'package:news_app_clean_architecture/shared/media/data/data_sources/device/device_image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/device/device_speech_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/shared/media/data/data_sources/remote/image_storage_service.dart';
import 'package:news_app_clean_architecture/shared/media/data/repository/image_picker_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_assistant_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/news_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/saved_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/speech_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/thumbnail_storage_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/user_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/news_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/media/domain/repository/image_picker_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_assistant_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/saved_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/speech_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/thumbnail_storage_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/apply_article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/control_reading.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_top_headlines.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/load_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/clear_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/draft_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/draft_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/read_aloud.dart';
import 'package:news_app_clean_architecture/shared/media/domain/use_cases/pick_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/search_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/suggest_article_edits.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/brief/brief_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/editor_assistant/editor_assistant_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/listen/listen_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/publish/publish_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/reader_lens/reader_lens_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_cubit.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/settings_local_data_source.dart';
import 'package:news_app_clean_architecture/features/settings/data/repository/settings_repository_impl.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/save_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/watch_settings.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  await _registerDataSources();
  _registerRepositories();
  _registerArticleUseCases();
  _registerAuthUseCases();
  _registerSettingsUseCases();
  _registerBlocs();
}

Future<void> _registerDataSources() async {
  final database = await AppDatabase.open();
  sl.registerSingleton<AppDatabase>(database);
  sl.registerSingleton<Dio>(Dio());
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));
  sl.registerSingleton<DeviceImagePicker>(DeviceImagePicker(ImagePicker()));
  sl.registerSingleton<ArticleFirestoreService>(ArticleFirestoreService(FirebaseFirestore.instance));
  sl.registerSingleton<ImageStorageService>(ImageStorageService(FirebaseStorage.instance));
  sl.registerSingleton<AssistantFunctionsService>(AssistantFunctionsService.forRegion());
  sl.registerSingleton<DeviceSpeechService>(DeviceSpeechService(FlutterTts()));
  await GoogleSignIn.instance.initialize();
  sl.registerSingleton<FirebaseAuthService>(
    FirebaseAuthService(FirebaseAuth.instance, GoogleSignIn.instance),
  );
  sl.registerSingleton<SettingsLocalDataSource>(
    SettingsLocalDataSource(await SharedPreferences.getInstance()),
  );
  sl.registerSingleton<DraftLocalDataSource>(
    DraftLocalDataSource(await SharedPreferences.getInstance()),
  );
}

/// Every repository is backed by its real service: the news provider,
/// SQLite for bookmarks, Firestore for articles, Cloud Storage for photos,
/// Firebase Auth for accounts and the platform key-value store for settings.
void _registerRepositories() {
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl()));
  sl.registerSingleton<NewsRepository>(NewsRepositoryImpl(sl()));
  sl.registerSingleton<SavedArticleRepository>(
    SavedArticleRepositoryImpl(sl<AppDatabase>().savedArticleDao, sl()),
  );
  sl.registerSingleton<UserArticleRepository>(UserArticleRepositoryImpl(sl()));
  sl.registerSingleton<ThumbnailStorageRepository>(ThumbnailStorageRepositoryImpl(sl(), sl()));
  sl.registerSingleton<ImagePickerRepository>(ImagePickerRepositoryImpl(sl()));
  sl.registerSingleton<ArticleAssistantRepository>(ArticleAssistantRepositoryImpl(sl()));
  sl.registerSingleton<SpeechRepository>(SpeechRepositoryImpl(sl()));
  sl.registerSingleton<ProfilePhotoRepository>(ProfilePhotoRepositoryImpl(sl()));
  sl.registerSingleton<SettingsRepository>(SettingsRepositoryImpl(sl(), sl()));
  sl.registerSingleton<DraftRepository>(DraftRepositoryImpl(sl(), sl()));
}

void _registerArticleUseCases() {
  sl.registerSingleton<GetTopHeadlinesUseCase>(GetTopHeadlinesUseCase(sl()));
  sl.registerSingleton<GetFeedUseCase>(GetFeedUseCase(sl(), sl()));
  sl.registerSingleton<SearchArticlesUseCase>(SearchArticlesUseCase(sl(), sl()));
  sl.registerSingleton<GetMyArticlesUseCase>(GetMyArticlesUseCase(sl(), sl()));
  sl.registerSingleton<PublishArticleUseCase>(PublishArticleUseCase(sl(), sl(), sl()));
  sl.registerSingleton<UpdateArticleUseCase>(UpdateArticleUseCase(sl(), sl(), sl()));
  sl.registerSingleton<DeleteArticleUseCase>(DeleteArticleUseCase(sl(), sl(), sl()));
  sl.registerSingleton<GetSavedArticlesUseCase>(GetSavedArticlesUseCase(sl()));
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));
  sl.registerSingleton<RemoveSavedArticleUseCase>(RemoveSavedArticleUseCase(sl()));
  sl.registerSingleton<PickImageUseCase>(PickImageUseCase(sl()));
  sl.registerSingleton<LoadDraftUseCase>(LoadDraftUseCase(sl()));
  sl.registerSingleton<SaveDraftUseCase>(SaveDraftUseCase(sl()));
  sl.registerSingleton<ClearDraftUseCase>(ClearDraftUseCase(sl()));
  sl.registerSingleton<SuggestArticleEditsUseCase>(SuggestArticleEditsUseCase(sl()));
  sl.registerSingleton<ApplyArticleLensUseCase>(ApplyArticleLensUseCase(sl()));
  sl.registerSingleton<ReadAloudUseCase>(ReadAloudUseCase(sl()));
  sl.registerSingleton<PauseReadingUseCase>(PauseReadingUseCase(sl()));
  sl.registerSingleton<ResumeReadingUseCase>(ResumeReadingUseCase(sl()));
  sl.registerSingleton<StopReadingUseCase>(StopReadingUseCase(sl()));
  sl.registerSingleton<WatchReadingStatusUseCase>(WatchReadingStatusUseCase(sl()));
}

void _registerAuthUseCases() {
  sl.registerSingleton<WatchAuthStateUseCase>(WatchAuthStateUseCase(sl()));
  sl.registerSingleton<SignInWithEmailUseCase>(SignInWithEmailUseCase(sl()));
  sl.registerSingleton<SignUpWithEmailUseCase>(SignUpWithEmailUseCase(sl()));
  sl.registerSingleton<SignInWithGoogleUseCase>(SignInWithGoogleUseCase(sl()));
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl()));
  sl.registerSingleton<UpdateProfileUseCase>(UpdateProfileUseCase(sl(), sl()));
}

void _registerSettingsUseCases() {
  sl.registerSingleton<WatchSettingsUseCase>(WatchSettingsUseCase(sl()));
  sl.registerSingleton<SaveSettingsUseCase>(SaveSettingsUseCase(sl()));
}

/// App-wide cubits live as long as the app; form cubits are created per
/// screen.
void _registerBlocs() {
  sl.registerLazySingleton<SessionCubit>(() => SessionCubit(sl(), sl()));
  sl.registerLazySingleton<SettingsCubit>(() => SettingsCubit(sl(), sl()));
  sl.registerLazySingleton<SavedArticlesCubit>(() => SavedArticlesCubit(sl(), sl(), sl()));
  sl.registerLazySingleton<FeedCubit>(() => FeedCubit(sl()));
  sl.registerLazySingleton<BriefCubit>(() => BriefCubit(sl()));
  sl.registerFactory<SearchCubit>(() => SearchCubit(sl()));
  sl.registerLazySingleton<ListenCubit>(() => ListenCubit(sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory<EditorAssistantCubit>(() => EditorAssistantCubit(sl()));
  sl.registerFactoryParam<ReaderLensCubit, ArticleEntity, void>(
    (article, _) => ReaderLensCubit(sl(), article: article),
  );
  sl.registerLazySingleton<MyArticlesCubit>(() => MyArticlesCubit(sl(), sl()));
  sl.registerFactoryParam<PublishCubit, ArticleEntity?, void>(
    (original, _) => PublishCubit(
      sl(),
      sl(),
      sl(),
      loadDraft: sl(),
      saveDraft: sl(),
      clearDraft: sl(),
      original: original,
    ),
  );
  sl.registerFactoryParam<EditProfileCubit, UserEntity, void>(
    (user, _) => EditProfileCubit(sl(), sl(), user: user),
  );
  sl.registerFactory<SignInCubit>(() => SignInCubit(sl(), sl()));
  sl.registerFactory<SignUpCubit>(() => SignUpCubit(sl(), sl()));
}
