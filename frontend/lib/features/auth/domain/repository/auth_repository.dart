import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<DataState<AuthUserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<DataState<AuthUserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<DataState<void>> signOut();

  Stream<AuthUserEntity?> get authStateChanges;

  AuthUserEntity? get currentUser;
}
