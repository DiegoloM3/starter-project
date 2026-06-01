import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../features/auth/data/data_sources/auth_remote_data_source.dart';
import '../features/auth/data/repository/auth_repository_impl.dart';
import '../features/auth/domain/repository/auth_repository.dart';
import '../features/auth/domain/use_cases/check_auth_use_case.dart';
import '../features/auth/domain/use_cases/delete_account_use_case.dart';
import '../features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import '../features/auth/domain/use_cases/sign_out_use_case.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

void initAuthDependencies() {
  // DataSource — único lugar que toca Firebase Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      sl<FirebaseAuth>(),
      sl<GoogleSignIn>(),
      sl<FirebaseFirestore>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));

  // Bloc — factory porque cada pantalla necesita estado limpio
  sl.registerFactory(
    () => AuthBloc(sl(), sl(), sl()),
  );
}
