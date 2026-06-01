import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:tortutip/features/auth/domain/use_cases/delete_account_use_case.dart';
import 'package:tortutip/features/categories/domain/use_cases/get_all_categories_use_case.dart';
import 'package:tortutip/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:tortutip/features/profile/data/repository/profile_repository_impl.dart';
import 'package:tortutip/features/profile/domain/repository/profile_repository.dart';
import 'package:tortutip/features/profile/domain/use_cases/delete_article_use_case.dart';
import 'package:tortutip/features/profile/domain/use_cases/get_published_articles_use_case.dart';
import 'package:tortutip/features/profile/domain/use_cases/get_saved_articles_use_case.dart';
import 'package:tortutip/features/profile/domain/use_cases/upload_avatar_use_case.dart';
import 'package:tortutip/features/profile/presentation/bloc/edit_profile_cubit.dart';
import 'package:tortutip/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:tortutip/shared/user/domain/use_cases/update_user_role_use_case.dart';

final sl = GetIt.instance;

void initProfileDependencies() {
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<FirebaseFirestore>(), sl<FirebaseStorage>()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetSavedArticlesUseCase>(
    () => GetSavedArticlesUseCase(sl<ProfileRepository>()),
  );

  sl.registerLazySingleton<GetPublishedArticlesUseCase>(
    () => GetPublishedArticlesUseCase(sl<ProfileRepository>()),
  );

  sl.registerLazySingleton<DeleteArticleUseCase>(
    () => DeleteArticleUseCase(sl<ProfileRepository>()),
  );

  sl.registerLazySingleton<UploadAvatarUseCase>(
    () => UploadAvatarUseCase(sl<ProfileRepository>()),
  );

  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(sl(), sl(), sl(), sl(), sl<GetAllCategoriesUseCase>(), sl<UpdateUserRoleUseCase>()),
  );

  sl.registerFactory<EditProfileCubit>(
    () => EditProfileCubit(sl(), sl(), sl<DeleteAccountUseCase>()),
  );
}
