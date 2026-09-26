import '../../../../core/resources/data_state.dart';
import '../entities/user_identity.dart';
import '../params/auth_params.dart';

abstract class AuthRepository {
  UserIdentity? get currentUser;
  Future<DataState<UserIdentity>> signIn(SignInParams params);
  Future<DataState<UserIdentity>> signUp(SignUpParams params);
  Future<DataState<void>> signOut();
}
