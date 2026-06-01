import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../features/onboarding/presentation/bloc/onboarding_cubit.dart';
import '../shared/user/data/data_sources/user_remote_data_source.dart';
import '../shared/user/data/repository/user_repository_impl.dart';
import '../shared/user/domain/repository/user_repository.dart';
import '../shared/user/domain/use_cases/get_current_user_use_case.dart';
import '../shared/user/domain/use_cases/get_user_category_ids_use_case.dart';
import '../shared/user/domain/use_cases/select_user_categories_use_case.dart';
import '../shared/user/domain/use_cases/update_user_profile_use_case.dart';
import '../shared/user/domain/use_cases/update_user_role_use_case.dart';
import '../shared/user/domain/use_cases/get_user_by_id_use_case.dart';
import '../shared/user/domain/use_cases/record_feed_swipe_use_case.dart';

final sl = GetIt.instance;

void initUserDependencies() {
  // DataSource
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(
      sl<FirebaseFirestore>(),
      sl<FirebaseAuth>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserRoleUseCase(sl()));
  sl.registerLazySingleton(() => SelectUserCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetUserCategoryIdsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => RecordFeedSwipeUseCase(sl<UserRepository>()));

  // Cubit de onboarding vive aquí porque depende de use_cases de user
  sl.registerFactory(() => OnboardingCubit(sl(), sl(), sl()));
}
