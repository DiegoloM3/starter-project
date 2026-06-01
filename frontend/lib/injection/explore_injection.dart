import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../features/articles/domain/use_cases/get_saved_article_ids_use_case.dart';
import '../features/articles/domain/use_cases/save_article_use_case.dart';
import '../features/articles/domain/use_cases/unsave_article_use_case.dart';
import '../features/categories/domain/use_cases/get_all_categories_use_case.dart';
import '../features/explore/data/data_sources/explore_remote_data_source.dart';
import '../features/explore/data/repository/explore_repository_impl.dart';
import '../features/explore/domain/repository/explore_repository.dart';
import '../features/explore/domain/use_cases/get_articles_by_category_use_case.dart';
import '../features/explore/presentation/bloc/category_list_cubit.dart';
import '../features/explore/presentation/bloc/explore_cubit.dart';

final sl = GetIt.instance;

void initExploreDependencies() {
  sl.registerLazySingleton<ExploreRemoteDataSource>(
    () => ExploreRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );

  // Repository
  sl.registerLazySingleton<ExploreRepository>(
    () => ExploreRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetArticlesByCategoryUseCase(sl()));

  // Cubits — factory, one new instance per screen
  sl.registerFactory(() => ExploreCubit(sl<GetAllCategoriesUseCase>()));
  sl.registerFactory(() => CategoryListCubit(
        sl<GetArticlesByCategoryUseCase>(),
        sl<GetSavedArticleIdsUseCase>(),
        sl<SaveArticleUseCase>(),
        sl<UnsaveArticleUseCase>(),
      ));
}
