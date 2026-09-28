
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/article/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/article/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/article/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/article/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';

void articleBlocsServiceLocator() {
  getIt.registerFactory<RemoteArticlesBloc>(
    () => RemoteArticlesBloc(getArticleUseCase: getIt<GetArticleUseCase>()),
  );
  
  getIt.registerSingleton<LocalArticleBloc>(
    LocalArticleBloc(
      getSavedArticleUseCase: getIt<GetSavedArticleUseCase>(),
      saveArticleUseCase: getIt<SaveArticleUseCase>(),
      removeArticleUseCase: getIt<RemoveArticleUseCase>(),
    ),
  );
  
}
