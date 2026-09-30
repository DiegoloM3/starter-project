import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/firebase_options.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/use_cases/get_saved_article.dart';
import 'features/daily_news/domain/use_cases/remove_article.dart';
import 'features/daily_news/domain/use_cases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'features/journalist_articles/data/data_sources/local/article_draft_local_data_source.dart';
import 'features/journalist_articles/data/data_sources/local/author_signature_local_data_source.dart';
import 'features/journalist_articles/data/data_sources/local/gallery_image_data_source.dart';
import 'features/journalist_articles/data/data_sources/local/text_to_speech_data_source.dart';
import 'features/journalist_articles/data/data_sources/remote/article_thumbnail_storage_data_source.dart';
import 'features/journalist_articles/data/data_sources/remote/published_articles_firestore_data_source.dart';
import 'features/journalist_articles/data/repository/article_narrator_repository_impl.dart';
import 'features/journalist_articles/data/repository/article_draft_repository_impl.dart';
import 'features/journalist_articles/data/repository/author_signature_repository_impl.dart';
import 'features/journalist_articles/data/repository/published_article_repository_impl.dart';
import 'features/journalist_articles/data/repository/thumbnail_picker_repository_impl.dart';
import 'features/journalist_articles/domain/repository/article_narrator_repository.dart';
import 'features/journalist_articles/domain/repository/article_draft_repository.dart';
import 'features/journalist_articles/domain/repository/author_signature_repository.dart';
import 'features/journalist_articles/domain/repository/published_article_repository.dart';
import 'features/journalist_articles/domain/repository/thumbnail_picker_repository.dart';
import 'features/journalist_articles/domain/use_cases/get_published_articles.dart';
import 'features/journalist_articles/domain/use_cases/discard_draft.dart';
import 'features/journalist_articles/domain/use_cases/pick_thumbnail_from_gallery.dart';
import 'features/journalist_articles/domain/use_cases/publish_article.dart';
import 'features/journalist_articles/domain/use_cases/read_article_aloud.dart';
import 'features/journalist_articles/domain/use_cases/resume_draft.dart';
import 'features/journalist_articles/domain/use_cases/save_draft.dart';
import 'features/journalist_articles/domain/use_cases/stop_reading_aloud.dart';
import 'features/journalist_articles/presentation/bloc/article_narration/article_narration_cubit.dart';
import 'features/journalist_articles/presentation/bloc/publish_article/publish_article_cubit.dart';
import 'features/journalist_articles/presentation/bloc/published_articles/published_articles_cubit.dart';

final sl = GetIt.instance;

// Run against the local Firebase Emulator Suite instead of the real project:
// flutter run --dart-define=USE_FIREBASE_EMULATORS=true
// The host machine is 10.0.2.2 from the Android emulator and 127.0.0.1 from the iOS simulator;
// override it with --dart-define=FIREBASE_EMULATOR_HOST=<ip> when using a physical device.
const bool _useFirebaseEmulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');
const String _firebaseEmulatorHostOverride = String.fromEnvironment('FIREBASE_EMULATOR_HOST');

String get _firebaseEmulatorHost {
  if (_firebaseEmulatorHostOverride.isNotEmpty) return _firebaseEmulatorHostOverride;
  return Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
}

Future<void> initializeDependencies() async {
  await _initializeFirebase();

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);
  
  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(),sl())
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
  
  sl.registerSingleton<RemoveArticleUseCase>(
    RemoveArticleUseCase(sl())
  );

  await _registerJournalistArticles();

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl())
  );

  sl.registerFactory<LocalArticleBloc>(
    ()=> LocalArticleBloc(sl(),sl(),sl())
  );


}

Future<void> _registerJournalistArticles() async {
  // Data sources
  sl.registerSingleton<PublishedArticlesFirestoreDataSource>(
    PublishedArticlesFirestoreDataSource(FirebaseFirestore.instance),
  );
  sl.registerSingleton<ArticleThumbnailStorageDataSource>(ArticleThumbnailStorageDataSource(FirebaseStorage.instance));
  sl.registerSingleton<GalleryImageDataSource>(GalleryImageDataSource(ImagePicker()));
  final preferences = await SharedPreferences.getInstance();
  sl.registerSingleton<AuthorSignatureLocalDataSource>(AuthorSignatureLocalDataSource(preferences));
  final appSupportDirectory = await getApplicationSupportDirectory();
  sl.registerSingleton<ArticleDraftLocalDataSource>(
    ArticleDraftLocalDataSource(preferences, Directory('${appSupportDirectory.path}/journalist_articles_draft')),
  );
  sl.registerSingleton<TextToSpeechDataSource>(TextToSpeechDataSource(FlutterTts()));

  // Repositories
  sl.registerSingleton<PublishedArticleRepository>(PublishedArticleRepositoryImpl(sl(), sl()));
  sl.registerSingleton<ThumbnailPickerRepository>(ThumbnailPickerRepositoryImpl(sl()));
  sl.registerSingleton<AuthorSignatureRepository>(AuthorSignatureRepositoryImpl(sl()));
  sl.registerSingleton<ArticleDraftRepository>(ArticleDraftRepositoryImpl(sl()));
  sl.registerSingleton<ArticleNarratorRepository>(ArticleNarratorRepositoryImpl(sl()));

  // Use cases
  sl.registerSingleton<PublishArticleUseCase>(PublishArticleUseCase(sl(), sl(), sl()));
  sl.registerSingleton<GetPublishedArticlesUseCase>(GetPublishedArticlesUseCase(sl()));
  sl.registerSingleton<PickThumbnailFromGalleryUseCase>(PickThumbnailFromGalleryUseCase(sl()));
  sl.registerSingleton<ResumeDraftUseCase>(ResumeDraftUseCase(sl(), sl()));
  sl.registerSingleton<SaveDraftUseCase>(SaveDraftUseCase(sl()));
  sl.registerSingleton<DiscardDraftUseCase>(DiscardDraftUseCase(sl()));
  sl.registerSingleton<ReadArticleAloudUseCase>(ReadArticleAloudUseCase(sl()));
  sl.registerSingleton<StopReadingAloudUseCase>(StopReadingAloudUseCase(sl()));

  // Cubits
  sl.registerFactory<PublishArticleCubit>(() => PublishArticleCubit(sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory<PublishedArticlesCubit>(() => PublishedArticlesCubit(sl()));
  sl.registerFactory<ArticleNarrationCubit>(() => ArticleNarrationCubit(sl(), sl()));
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Fail within 30 s instead of retrying for up to 10 minutes, so the publish screen
  // can report the problem and offer to retry.
  FirebaseStorage.instance
    ..setMaxUploadRetryTime(const Duration(seconds: 30))
    ..setMaxOperationRetryTime(const Duration(seconds: 30));
  if (_useFirebaseEmulators) {
    await _connectToFirebaseEmulators();
  }
}

Future<void> _connectToFirebaseEmulators() async {
  FirebaseFirestore.instance.useFirestoreEmulator(_firebaseEmulatorHost, 8080);
  await FirebaseStorage.instance.useStorageEmulator(_firebaseEmulatorHost, 9199);
}