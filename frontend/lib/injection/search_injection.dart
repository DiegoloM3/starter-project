import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tortutip/features/search/data/data_sources/search_local_data_source.dart';
import 'package:tortutip/features/search/data/data_sources/search_remote_data_source.dart';
import 'package:tortutip/features/search/data/repository/search_repository_impl.dart';
import 'package:tortutip/features/search/domain/repository/search_repository.dart';
import 'package:tortutip/features/search/domain/use_cases/get_recent_searches_use_case.dart';
import 'package:tortutip/features/search/domain/use_cases/remove_recent_search_use_case.dart';
import 'package:tortutip/features/search/domain/use_cases/save_recent_search_use_case.dart';
import 'package:tortutip/features/search/domain/use_cases/search_articles_use_case.dart';
import 'package:tortutip/features/search/domain/use_cases/search_categories_use_case.dart';
import 'package:tortutip/features/search/domain/use_cases/search_creators_use_case.dart';
import 'package:tortutip/features/search/presentation/bloc/search_cubit.dart';
import 'package:tortutip/injection/injection_container.dart';

void initSearchDependencies() {
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<SearchLocalDataSource>(
    () => SearchLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      sl<SearchRemoteDataSource>(),
      sl<SearchLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton(() => SearchArticlesUseCase(sl()));
  sl.registerLazySingleton(() => SearchCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => SearchCreatorsUseCase(sl()));
  sl.registerLazySingleton(() => GetRecentSearchesUseCase(sl()));
  sl.registerLazySingleton(() => SaveRecentSearchUseCase(sl()));
  sl.registerLazySingleton(() => RemoveRecentSearchUseCase(sl()));
  sl.registerFactory(
    () => SearchCubit(
      sl<SearchArticlesUseCase>(),
      sl<SearchCategoriesUseCase>(),
      sl<SearchCreatorsUseCase>(),
      sl<GetRecentSearchesUseCase>(),
      sl<SaveRecentSearchUseCase>(),
      sl<RemoveRecentSearchUseCase>(),
    ),
  );
}
