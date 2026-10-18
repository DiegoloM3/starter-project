import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'features/articles/data/data_sources/remote/article_image_remote_data_source.dart';
import 'features/articles/data/data_sources/remote/article_remote_data_source.dart';
import 'features/articles/data/data_sources/remote/saved_articles_remote_data_source.dart';
import 'features/articles/data/repository/article_repository_impl.dart';
import 'features/articles/data/repository/saved_articles_repository_impl.dart';
import 'features/articles/domain/entities/article.dart';
import 'features/articles/domain/repository/article_repository.dart';
import 'features/articles/domain/repository/saved_articles_repository.dart';
import 'features/articles/domain/usecases/delete_article.dart';
import 'features/articles/domain/usecases/get_article.dart';
import 'features/articles/domain/usecases/get_for_you_articles.dart';
import 'features/articles/domain/usecases/get_trending_topics.dart';
import 'features/articles/presentation/bloc/trends/trends_cubit.dart';
import 'features/articles/domain/usecases/get_saved_articles.dart';
import 'features/articles/domain/usecases/publish_article.dart';
import 'features/articles/domain/usecases/remove_saved_article.dart';
import 'features/articles/domain/usecases/save_article.dart';
import 'features/articles/domain/usecases/update_article.dart';
import 'features/articles/domain/usecases/upload_article_image.dart';
import 'features/articles/presentation/bloc/article_detail/article_detail_cubit.dart';
import 'features/articles/presentation/bloc/article_editor/article_editor_cubit.dart';
import 'features/articles/presentation/bloc/articles/articles_cubit.dart';
import 'features/articles/presentation/bloc/saved_articles/saved_articles_cubit.dart';
import 'features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'shared/users/data/data_sources/remote/user_profile_remote_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/delete_account.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/domain/usecases/watch_current_user.dart';
import 'features/auth/presentation/bloc/auth/auth_cubit.dart';
import 'features/auth/presentation/bloc/auth_form/auth_form_cubit.dart';
import 'features/comments/data/data_sources/remote/comment_remote_data_source.dart';
import 'features/comments/data/repository/comment_repository_impl.dart';
import 'features/comments/domain/repository/comment_repository.dart';
import 'features/comments/domain/usecases/add_comment.dart';
import 'features/comments/domain/usecases/delete_comment.dart';
import 'features/comments/domain/usecases/get_comments.dart';
import 'features/comments/presentation/bloc/comments/comments_cubit.dart';
import 'features/articles/data/data_sources/remote/reading_history_remote_data_source.dart';
import 'features/articles/data/repository/reading_history_repository_impl.dart';
import 'features/articles/domain/repository/reading_history_repository.dart';
import 'features/articles/domain/usecases/get_articles_by_authors.dart';
import 'features/articles/domain/usecases/get_reading_history.dart';
import 'features/articles/domain/usecases/record_article_view.dart';
import 'features/articles/presentation/bloc/reading_history/reading_history_cubit.dart';
import 'features/profiles/data/data_sources/remote/follow_remote_data_source.dart';
import 'features/profiles/data/data_sources/remote/user_photo_remote_data_source.dart';
import 'features/profiles/domain/usecases/update_profile.dart';
import 'features/profiles/presentation/bloc/edit_profile/edit_profile_cubit.dart';
import 'features/profiles/data/repository/profile_repository_impl.dart';
import 'features/profiles/domain/repository/profile_repository.dart';
import 'features/profiles/domain/usecases/follow_user.dart';
import 'features/profiles/domain/usecases/get_follow_stats.dart';
import 'features/profiles/domain/usecases/get_followed_user_ids.dart';
import 'features/profiles/domain/usecases/get_user_profile.dart';
import 'features/profiles/domain/usecases/is_following.dart';
import 'features/profiles/domain/usecases/unfollow_user.dart';
import 'features/profiles/presentation/bloc/user_profile/user_profile_cubit.dart';
import 'features/settings/data/data_sources/local/settings_local_data_source.dart';
import 'features/settings/data/data_sources/remote/account_settings_remote_data_source.dart';
import 'features/settings/data/repository/account_settings_repository_impl.dart';
import 'features/settings/domain/repository/account_settings_repository.dart';
import 'features/settings/domain/usecases/get_notifications_enabled.dart';
import 'features/settings/domain/usecases/set_notifications_enabled.dart';
import 'features/settings/presentation/bloc/notifications/notifications_cubit.dart';
import 'features/settings/data/repository/settings_repository_impl.dart';
import 'features/settings/domain/repository/settings_repository.dart';
import 'features/settings/domain/usecases/get_appearance.dart';
import 'features/settings/domain/usecases/save_appearance.dart';
import 'features/settings/presentation/bloc/appearance/appearance_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  _registerProviders();
  _registerSettings(preferences);
  _registerAuth();
  _registerArticles();
  _registerComments();
  _registerProfiles();
}

/// The Firebase services are registered once, so the data sources receive them instead of creating them.
void _registerProviders() {
  sl
    ..registerLazySingleton(() => FirebaseAuth.instance)
    ..registerLazySingleton(() => FirebaseFirestore.instance)
    ..registerLazySingleton(() => FirebaseStorage.instance)
    ..registerLazySingleton(Uuid.new);
}

void _registerSettings(SharedPreferences preferences) {
  sl
    ..registerLazySingleton(() => SettingsLocalDataSource(preferences))
    ..registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetAppearanceUseCase(sl()))
    ..registerLazySingleton(() => SaveAppearanceUseCase(sl()))
    ..registerFactory(() => AppearanceCubit(sl(), sl()))
    ..registerLazySingleton(() => AccountSettingsRemoteDataSource(sl(), sl()))
    ..registerLazySingleton<AccountSettingsRepository>(() => AccountSettingsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetNotificationsEnabledUseCase(sl()))
    ..registerLazySingleton(() => SetNotificationsEnabledUseCase(sl()))
    ..registerFactory(() => NotificationsCubit(sl(), sl()));
}

void _registerAuth() {
  sl
    ..registerLazySingleton(() => AuthRemoteDataSource(sl()))
    ..registerLazySingleton(() => UserProfileRemoteDataSource(sl()))
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()))
    ..registerLazySingleton(() => SignInUseCase(sl()))
    ..registerLazySingleton(() => SignUpUseCase(sl()))
    ..registerLazySingleton(() => SignOutUseCase(sl()))
    ..registerLazySingleton(() => WatchCurrentUserUseCase(sl()))
    ..registerFactory(() => AuthCubit(sl(), sl()))
    ..registerLazySingleton(() => DeleteAccountUseCase(sl()))
    ..registerFactory(() => AuthFormCubit(sl(), sl(), sl()));
}

void _registerArticles() {
  sl
    ..registerLazySingleton(() => ArticleRemoteDataSource(sl(), sl()))
    ..registerLazySingleton(() => ArticleImageRemoteDataSource(sl(), sl(), sl()))
    ..registerLazySingleton(() => SavedArticlesRemoteDataSource(sl(), sl()))
    ..registerLazySingleton(() => ReadingHistoryRemoteDataSource(sl(), sl()))
    ..registerLazySingleton<ArticleRepository>(() => ArticleRepositoryImpl(sl(), sl()))
    ..registerLazySingleton<SavedArticlesRepository>(() => SavedArticlesRepositoryImpl(sl(), sl()))
    ..registerLazySingleton<ReadingHistoryRepository>(() => ReadingHistoryRepositoryImpl(sl(), sl()))
    ..registerLazySingleton(() => GetForYouArticlesUseCase(sl()))
    ..registerLazySingleton(() => GetTrendingTopicsUseCase(sl()))
    ..registerLazySingleton(() => GetArticleUseCase(sl()))
    ..registerLazySingleton(() => GetArticlesByAuthorsUseCase(sl()))
    ..registerLazySingleton(() => PublishArticleUseCase(sl()))
    ..registerLazySingleton(() => UpdateArticleUseCase(sl()))
    ..registerLazySingleton(() => DeleteArticleUseCase(sl()))
    ..registerLazySingleton(() => UploadArticleImageUseCase(sl()))
    ..registerLazySingleton(() => GetSavedArticlesUseCase(sl()))
    ..registerLazySingleton(() => SaveArticleUseCase(sl()))
    ..registerLazySingleton(() => RemoveSavedArticleUseCase(sl()))
    ..registerLazySingleton(() => RecordArticleViewUseCase(sl()))
    ..registerLazySingleton(() => GetReadingHistoryUseCase(sl()))
    ..registerFactory(() => ArticlesCubit(sl(), sl(), sl()))
    ..registerFactory(() => SavedArticlesCubit(sl(), sl(), sl()))
    ..registerFactory(() => ArticleEditorCubit(sl(), sl(), sl()))
    ..registerFactory(() => ReadingHistoryCubit(sl()))
    ..registerFactory(() => TrendsCubit(sl()))
    ..registerFactoryParam<ArticleDetailCubit, ArticleEntity, void>(
      (article, _) => ArticleDetailCubit(article, sl(), sl(), sl()),
    );
}

void _registerComments() {
  sl
    ..registerLazySingleton(() => CommentRemoteDataSource(sl(), sl()))
    ..registerLazySingleton<CommentRepository>(() => CommentRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetCommentsUseCase(sl()))
    ..registerLazySingleton(() => AddCommentUseCase(sl()))
    ..registerLazySingleton(() => DeleteCommentUseCase(sl()))
    ..registerFactoryParam<CommentsCubit, String, void>((articleId, _) => CommentsCubit(articleId, sl(), sl(), sl()));
}

void _registerProfiles() {
  sl
    ..registerLazySingleton(() => FollowRemoteDataSource(sl(), sl()))
    ..registerLazySingleton(() => UserPhotoRemoteDataSource(sl(), sl(), sl()))
    ..registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl(), sl(), sl()))
    ..registerLazySingleton(() => UpdateProfileUseCase(sl()))
    ..registerFactory(() => EditProfileCubit(sl()))
    ..registerLazySingleton(() => GetUserProfileUseCase(sl()))
    ..registerLazySingleton(() => GetFollowStatsUseCase(sl()))
    ..registerLazySingleton(() => IsFollowingUseCase(sl()))
    ..registerLazySingleton(() => FollowUserUseCase(sl()))
    ..registerLazySingleton(() => UnfollowUserUseCase(sl()))
    ..registerLazySingleton(() => GetFollowedUserIdsUseCase(sl()))
    ..registerFactoryParam<UserProfileCubit, String, void>(
      (uid, _) => UserProfileCubit(uid, sl(), sl(), sl(), sl(), sl(), sl()),
    );
}
