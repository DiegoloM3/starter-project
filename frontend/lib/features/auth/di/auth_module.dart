import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_auth_stream.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up_with_email.dart';

@module
abstract class AuthModule {
  @lazySingleton
  SignInWithEmail signInWithEmail(AuthRepository repository) {
    return SignInWithEmail(repository);
  }

  @lazySingleton
  SignUpWithEmail signUpWithEmail(AuthRepository repository) {
    return SignUpWithEmail(repository);
  }

  @lazySingleton
  SignInWithGoogle signInWithGoogle(AuthRepository repository) {
    return SignInWithGoogle(repository);
  }

  @lazySingleton
  SignOut signOut(AuthRepository repository) {
    return SignOut(repository);
  }

  @lazySingleton
  GetCurrentUser getCurrentUser(AuthRepository repository) {
    return GetCurrentUser(repository);
  }

  @lazySingleton
  GetAuthStream getAuthStream(AuthRepository repository) {
    return GetAuthStream(repository);
  }
}
