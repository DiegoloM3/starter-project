import '../../../../core/resources/data_state.dart';
import '../../../../shared/users/domain/entities/user.dart';
import '../params/sign_in_params.dart';
import '../params/sign_up_params.dart';

abstract class AuthRepository {
  /// Creates the account and its public profile as a reader.
  Future<DataState<UserEntity>> signUp(SignUpParams params);

  Future<DataState<UserEntity>> signIn(SignInParams params);

  Future<DataState<void>> signOut();

  /// Deletes the account and the private data of the user after confirming their password.
  /// Their articles and comments are kept.
  Future<DataState<void>> deleteAccount(String password);

  /// Emits the signed in user, or null when nobody is signed in.
  Stream<UserEntity?> watchCurrentUser();
}
