import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/articles/domain/entities/article.dart';
import 'features/articles/domain/usecases/delete_article.dart';
import 'features/articles/domain/usecases/get_article.dart';
import 'features/articles/domain/usecases/get_articles.dart';
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
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/domain/usecases/watch_current_user.dart';
import 'features/auth/presentation/bloc/auth/auth_cubit.dart';
import 'features/auth/presentation/bloc/auth_form/auth_form_cubit.dart';
import 'features/settings/data/data_sources/local/settings_local_data_source.dart';
import 'features/settings/data/repository/settings_repository_impl.dart';
import 'features/settings/domain/repository/settings_repository.dart';
import 'features/settings/domain/usecases/get_appearance.dart';
import 'features/settings/domain/usecases/save_appearance.dart';
import 'features/settings/presentation/bloc/appearance/appearance_cubit.dart';

final sl = GetIt.instance;

// The data sources and repositories of auth and articles are registered here once the data layer
// connects their use cases to Firebase.
Future<void> initializeDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  _registerSettings(preferences);
  _registerAuth();
  _registerArticles();
}

void _registerSettings(SharedPreferences preferences) {
  sl
    ..registerLazySingleton(() => SettingsLocalDataSource(preferences))
    ..registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetAppearanceUseCase(sl()))
    ..registerLazySingleton(() => SaveAppearanceUseCase(sl()))
    ..registerFactory(() => AppearanceCubit(sl(), sl()));
}

void _registerAuth() {
  sl
    ..registerLazySingleton(SignInUseCase.new)
    ..registerLazySingleton(SignUpUseCase.new)
    ..registerLazySingleton(SignOutUseCase.new)
    ..registerLazySingleton(WatchCurrentUserUseCase.new)
    ..registerFactory(() => AuthCubit(sl(), sl()))
    ..registerFactory(() => AuthFormCubit(sl(), sl()));
}

void _registerArticles() {
  sl
    ..registerLazySingleton(GetArticlesUseCase.new)
    ..registerLazySingleton(GetArticleUseCase.new)
    ..registerLazySingleton(PublishArticleUseCase.new)
    ..registerLazySingleton(UpdateArticleUseCase.new)
    ..registerLazySingleton(DeleteArticleUseCase.new)
    ..registerLazySingleton(UploadArticleImageUseCase.new)
    ..registerLazySingleton(GetSavedArticlesUseCase.new)
    ..registerLazySingleton(SaveArticleUseCase.new)
    ..registerLazySingleton(RemoveSavedArticleUseCase.new)
    ..registerFactory(() => ArticlesCubit(sl()))
    ..registerFactory(() => SavedArticlesCubit(sl(), sl(), sl()))
    ..registerFactory(() => ArticleEditorCubit(sl(), sl(), sl()))
    ..registerFactoryParam<ArticleDetailCubit, ArticleEntity, void>(
      (article, _) => ArticleDetailCubit(article, sl(), sl()),
    );
}
