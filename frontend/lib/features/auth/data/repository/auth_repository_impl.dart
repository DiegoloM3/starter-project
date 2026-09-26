import '../../../../core/resources/data_state.dart';
import '../../domain/entities/user_identity.dart';
import '../../domain/params/auth_params.dart';
import '../../domain/repository/auth_repository.dart';
import '../data_sources/firebase_auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  UserIdentity? get currentUser {
    final user = _dataSource.currentUser;
    return user == null ? null : _toEntity(user);
  }

  @override
  Future<DataState<UserIdentity>> signIn(SignInParams params) async {
    try {
      final credential = await _dataSource.signIn(params.email, params.password);
      return DataSuccess(_toEntity(credential.user!));
    } catch (error) {
      return DataFailed(AppFailure(_authMessage(error), cause: error));
    }
  }

  @override
  Future<DataState<UserIdentity>> signUp(SignUpParams params) async {
    try {
      final credential = await _dataSource.signUp(
        params.email,
        params.password,
        params.displayName,
      );
      return DataSuccess(_toEntity(credential.user!));
    } catch (error) {
      return DataFailed(AppFailure(_authMessage(error), cause: error));
    }
  }

  @override
  Future<DataState<void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const DataSuccess(null);
    } catch (error) {
      return DataFailed(AppFailure('Unable to sign out. Please try again.', cause: error));
    }
  }

  UserIdentity _toEntity(dynamic user) => UserIdentity(
        uid: user.uid as String,
        email: (user.email as String?) ?? '',
        displayName: (user.displayName as String?) ?? '',
      );

  String _authMessage(Object error) {
    final code = error.toString();
    if (code.contains('invalid-credential') || code.contains('user-not-found')) {
      return 'The email or password is incorrect.';
    }
    if (code.contains('email-already-in-use')) return 'That email is already registered.';
    if (code.contains('weak-password')) return 'Choose a stronger password.';
    if (code.contains('invalid-email')) return 'Enter a valid email address.';
    return 'Authentication failed. Please try again.';
  }
}
