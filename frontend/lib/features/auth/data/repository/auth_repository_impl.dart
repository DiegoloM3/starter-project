import 'package:rxdart/rxdart.dart';

import '../../../../core/resources/data_state.dart';
import '../../../../shared/users/domain/entities/user.dart';
import '../../domain/params/sign_in_params.dart';
import '../../domain/params/sign_up_params.dart';
import '../../domain/repository/auth_repository.dart';
import '../data_sources/remote/auth_remote_data_source.dart';
import '../../../../shared/users/data/data_sources/remote/user_profile_remote_data_source.dart';
import '../../../../shared/users/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authDataSource;
  final UserProfileRemoteDataSource _profileDataSource;

  AuthRepositoryImpl(this._authDataSource, this._profileDataSource);

  /// If the profile cannot be created, the new account is deleted so the email can be used again.
  @override
  Future<DataState<UserEntity>> signUp(SignUpParams params) {
    return runAsDataState(() async {
      final account = await _authDataSource.createAccount(email: params.email, password: params.password);
      try {
        await _profileDataSource.createProfile(
          uid: account.uid,
          firstName: params.firstName,
          lastName: params.lastName,
          email: account.email,
        );
      } on Exception {
        await _authDataSource.deleteSignedInAccount();
        rethrow;
      }
      return _newReader(account.uid, params).toEntity();
    });
  }

  @override
  Future<DataState<UserEntity>> signIn(SignInParams params) {
    return runAsDataState(() async {
      final uid = await _authDataSource.signIn(email: params.email, password: params.password);
      final profile = await _profileDataSource.getProfile(uid);
      return profile.toEntity();
    });
  }

  @override
  Future<DataState<void>> signOut() => runAsDataState(_authDataSource.signOut);

  /// The account is deleted last: if anything fails before, the user can still sign in and retry.
  @override
  Future<DataState<void>> deleteAccount(String password) {
    return runAsDataState(() async {
      final uid = _authDataSource.signedInUserId;
      await _authDataSource.reauthenticate(password);
      await _profileDataSource.deleteUserData(uid);
      await _authDataSource.deleteSignedInAccount();
    });
  }

  /// Follows the profile of the signed in user, so changes such as a new role show up at once.
  /// If the profile cannot be read, the app treats the user as signed out.
  @override
  Stream<UserEntity?> watchCurrentUser() {
    return _authDataSource
        .watchSignedInUserId()
        .switchMap((uid) => uid == null ? Stream<UserEntity?>.value(null) : _watchExistingProfile(uid))
        .onErrorReturn(null);
  }

  Stream<UserEntity?> _watchExistingProfile(String uid) {
    return _profileDataSource.watchProfile(uid).whereType<UserModel>().map((profile) => profile.toEntity());
  }

  UserModel _newReader(String uid, SignUpParams params) {
    return UserModel(uid: uid, firstName: params.firstName, lastName: params.lastName, bio: '', role: UserRole.reader);
  }
}
