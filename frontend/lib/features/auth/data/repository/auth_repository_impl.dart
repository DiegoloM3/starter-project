import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/auth_firebase_service.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// [AuthRepository] implementation delegating to [AuthFirebaseService].
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  static final _log = Logger('AuthRepositoryImpl');

  final AuthFirebaseService _firebaseService;

  AuthRepositoryImpl(this._firebaseService);

  @override
  Stream<UserEntity?> get authStateChanges => _firebaseService.authStateChanges;

  @override
  /// Signs in via Firebase and wraps the user in [DataState].
  Future<DataState<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _firebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return DataSuccess(user);
    } catch (e, st) {
      _log.severe('login → failed', e, st);
      final message = e is String ? e : e.toString().replaceFirst('Exception: ', '');
      return DataGenericFailed(message);
    }
  }

  @override
  Future<DataState<UserEntity>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await _firebaseService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      return DataSuccess(user);
    } catch (e, st) {
      _log.severe('register → failed', e, st);
      final message = e is String ? e : e.toString().replaceFirst('Exception: ', '');
      return DataGenericFailed(message);
    }
  }

  @override
  Future<DataState<void>> logout() async {
    try {
      await _firebaseService.signOut();
      return const DataSuccess(null);
    } catch (e, st) {
      _log.severe('logout → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  @override
  Future<DataState<UserEntity?>> updateCurrentUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = await _firebaseService.updateAuthProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return DataSuccess(user);
    } catch (e, st) {
      _log.severe('updateCurrentUserProfile → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  @override
  Future<DataState<void>> deleteCurrentUser() async {
    try {
      await _firebaseService.deleteCurrentUser();
      return const DataSuccess(null);
    } catch (e, st) {
      _log.severe('deleteCurrentUser → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  @override
  Future<DataState<UserEntity?>> getCurrentUser() async {
    try {
      final user = _firebaseService.currentUser;
      return DataSuccess(user);
    } catch (e, st) {
      _log.severe('getCurrentUser → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }
}
