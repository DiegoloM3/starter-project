import 'package:news_app_clean_architecture/shared/auth/data/data_sources/avatar_storage_data_source.dart';
import 'package:news_app_clean_architecture/shared/auth/data/data_sources/firebase_auth_data_source.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/params/auth_credentials.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/params/password_change.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/params/profile_photo.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _auth;
  final AvatarStorageDataSource _avatarStorage;

  AuthRepositoryImpl(this._auth, this._avatarStorage);

  @override
  Stream<AuthUserEntity?> authStateChanges() =>
      _auth.authStateChanges().map((m) => m?.toEntity());

  @override
  AuthUserEntity? get currentUser => _auth.currentUserSnapshot?.toEntity();

  @override
  Future<AuthUserEntity> signIn(AuthCredentials credentials) async {
    final model = await _auth.signInWithEmailAndPassword(
        credentials.email.trim(), credentials.password);
    return model.toEntity();
  }

  @override
  Future<AuthUserEntity> signUp(AuthCredentials credentials) async {
    final created = await _auth.createUserWithEmailAndPassword(
        credentials.email.trim(), credentials.password);
    final name = credentials.displayName?.trim();
    if (name == null || name.isEmpty) {
      return created.toEntity();
    }
    final named = await _auth.updateDisplayName(name);
    return named.toEntity();
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<AuthUserEntity> updateDisplayName(String displayName) async {
    final model = await _auth.updateDisplayName(displayName);
    return model.toEntity();
  }

  @override
  Future<void> updatePassword(PasswordChange change) =>
      _auth.updatePassword(change.currentPassword, change.newPassword);

  @override
  Future<AuthUserEntity> updateProfilePhoto(ProfilePhoto photo) async {
    final url = await _avatarStorage.uploadAvatarForCurrentUser(
      AvatarUploadRequest(bytes: photo.bytes, fileName: photo.fileName),
    );
    final model = await _auth.updatePhotoUrl(url);
    return model.toEntity();
  }
}
