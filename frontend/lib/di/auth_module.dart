import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/firebase_auth_data_source.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';

void registerAuthModule(GetIt sl) {
  // Data Source
  sl.registerSingleton<FirebaseAuthDataSource>(
    FirebaseAuthDataSource(sl<FirebaseAuth>()),
  );

  // Repository
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl<FirebaseAuthDataSource>()),
  );

  // Use Cases
  sl.registerSingleton<SignInUseCase>(SignInUseCase(sl()));
  sl.registerSingleton<SignUpUseCase>(SignUpUseCase(sl()));
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl()));

  // BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl(), sl(), sl(), sl()),
  );
}
