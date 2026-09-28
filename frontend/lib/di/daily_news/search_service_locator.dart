

import 'package:news_app_clean_architecture/di/service_locator.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/search_history_local_data_source/search_history_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/search_history_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/search_history_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/search/get_search_history_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/search/remove_search_term_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/search/save_search_term_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/article_search_bloc.dart';

void searchServiceLocator() {
  getIt.registerLazySingleton<SearchHistoryLocalDataSource>(() => SearchHistoryLocalDataSource());
  getIt.registerLazySingleton<SearchHistoryRepository>(
    () => SearchHistoryRepositoryImpl(dataSource: getIt<SearchHistoryLocalDataSource>()),
  );
  getIt.registerLazySingleton<GetSearchHistoryUseCase>(() => GetSearchHistoryUseCase(repository: getIt<SearchHistoryRepository>()));
  getIt.registerLazySingleton<SaveSearchTermUseCase>(() => SaveSearchTermUseCase(repository: getIt<SearchHistoryRepository>()));
  getIt.registerLazySingleton<RemoveSearchTermUseCase>(() => RemoveSearchTermUseCase(repository: getIt<SearchHistoryRepository>()));

  getIt.registerFactoryParam<ArticleSearchBloc, List<ArticleEntity>, void>(
    (articles, _) => ArticleSearchBloc(
      articles: articles,
      getSearchHistoryUseCase: getIt<GetSearchHistoryUseCase>(),
      saveSearchTermUseCase: getIt<SaveSearchTermUseCase>(),
      removeSearchTermUseCase: getIt<RemoveSearchTermUseCase>(),
    ),
  );
}