import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/shared/firebase/data/data_sources/firebase_failure_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _service;

  const AuthRepositoryImpl(this._service);

  @override
  Stream<UserEntity?> watchAuthState() =>
      _service.authStateChanges().map((model) => model?.toEntity());

  @override
  UserEntity? get currentUser => _service.currentUser?.toEntity();

  @override
  Future<DataState<UserEntity>> signInWithEmail(SignInParams params) {
    return _guard(() async {
      final model = await _service.signInWithEmail(
        email: params.trimmedEmail,
        password: params.password,
      );
      return model.toEntity();
    });
  }

  @override
  Future<DataState<UserEntity>> signUpWithEmail(SignUpParams params) {
    return _guard(() async {
      final model = await _service.signUpWithEmail(
        displayName: params.trimmedDisplayName,
        email: params.trimmedEmail,
        password: params.password,
      );
      return model.toEntity();
    });
  }

  @override
  Future<DataState<UserEntity>> signInWithGoogle() {
    return _guard(() async => (await _service.signInWithGoogle()).toEntity());
  }

  @override
  Future<DataState<UserEntity>> updateProfile({String? displayName, String? photoUrl}) {
    return _guard(() async {
      final model = await _service.updateProfile(displayName: displayName, photoUrl: photoUrl);
      return model.toEntity();
    });
  }

  @override
  Future<DataState<void>> signOut() => _guard(_service.signOut);

  Future<DataState<T>> _guard<T>(Future<T> Function() operation) =>
      runGuarded(operation, onError: FirebaseFailureMapper.map);
}
