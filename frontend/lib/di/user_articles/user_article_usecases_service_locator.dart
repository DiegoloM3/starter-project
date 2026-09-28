

import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/use_cases/delete_user_article_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/use_cases/get_user_articles_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/use_cases/upload_user_article_usecase.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';

void userArticleUseCasesServiceLocator() {
  getIt.registerLazySingleton<UploadUserArticleUseCase>(
    () => UploadUserArticleUseCase(repository: getIt<UserArticleRepository>()),
  );
  getIt.registerLazySingleton<GetUserArticlesUseCase>(
    () => GetUserArticlesUseCase(repository: getIt<UserArticleRepository>()),
  );
  getIt.registerLazySingleton<DeleteUserArticleUseCase>(
    () => DeleteUserArticleUseCase(repository: getIt<UserArticleRepository>()),
  );
}