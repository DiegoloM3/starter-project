

import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/article/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/article/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/article/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/article/save_article.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';

void articleUseCasesServiceLocator() {
  getIt.registerSingleton<GetArticleUseCase>(
    GetArticleUseCase(articleRepository: getIt<ArticleRepository>()),
  );
  getIt.registerSingleton<GetSavedArticleUseCase>(
    GetSavedArticleUseCase(articleRepository: getIt<ArticleRepository>()),
  );
  getIt.registerSingleton<SaveArticleUseCase>(
    SaveArticleUseCase(articleRepository: getIt<ArticleRepository>()),
  );
  getIt.registerSingleton<RemoveArticleUseCase>(
    RemoveArticleUseCase(articleRepository: getIt<ArticleRepository>()),
  );
}