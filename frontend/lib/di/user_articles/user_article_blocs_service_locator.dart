
import 'package:news_app_clean_architecture/features/user_articles/domain/use_cases/delete_user_article_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/use_cases/get_user_articles_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/use_cases/upload_user_article_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/user_articles_list/user_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/upload_article/upload_user_article_bloc.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';

void userArticleBlocsServiceLocator() {
  getIt.registerFactory<UploadUserArticleBloc>(
    () => UploadUserArticleBloc(uploadArticleUseCase: getIt<UploadUserArticleUseCase>()),
  );
  getIt.registerLazySingleton<UserArticlesBloc>(
    () => UserArticlesBloc(
      getMyArticlesUseCase: getIt<GetUserArticlesUseCase>(),
      deleteArticleUseCase: getIt<DeleteUserArticleUseCase>(),
    ),
  );
}