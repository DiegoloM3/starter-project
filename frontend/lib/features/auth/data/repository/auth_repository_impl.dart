import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/google_sign_in_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/user_document_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Orchestrates all auth operations by coordinating three data sources:
///   - [FirebaseAuthService] — Firebase Auth SDK calls
///   - [GoogleSignInService] — Google Sign-In SDK calls
///   - [UserDocumentService] — Firestore `users/{uid}` writes
///
/// Follows design D5 for the signInWithGoogle 5-step orchestration.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final GoogleSignInService _googleService;
  final UserDocumentService _docService;

  AuthRepositoryImpl(this._authService, this._googleService, this._docService);

  @override
  Future<DataState<AuthUserEntity>> signInAnonymously() async {
    try {
      final user = await _authService.signInAnonymously();
      return DataSuccess(AuthUserModel.fromRawData(user).toEntity());
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<DataState<AuthUserEntity>> signInWithEmail(
    SignInParams params,
  ) async {
    try {
      final user =
          await _authService.signInWithEmail(params.email, params.password);
      return DataSuccess(AuthUserModel.fromRawData(user).toEntity());
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<DataState<AuthUserEntity>> signUpWithEmail(
    SignUpParams params,
  ) async {
    try {
      final created =
          await _authService.signUpWithEmail(params.email, params.password);
      // FirebaseAuth.createUserWithEmailAndPassword does NOT accept a
      // displayName — it must be set via updateDisplayName + reload after
      // creation. Without this step the FirebaseAuth profile and the
      // Firestore mirror would both store a null displayName.
      final updated =
          await _authService.updateDisplayName(created, params.displayName);
      final entity = AuthUserModel.fromRawData(updated).toEntity();
      await _docService.upsertUser(entity);
      return DataSuccess(entity);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(UnknownException(message: e.toString()));
    }
  }

  /// Google sign-in — 5-step orchestration per design D5:
  /// 1. Google sign-in → account
  /// 2. Get idToken + accessToken from account
  /// 3. Build GoogleAuthCredential
  /// 4. Firebase signInWithCredential → User
  /// 5. Upsert users/{uid} document
  @override
  Future<DataState<AuthUserEntity>> signInWithGoogle() async {
    try {
      // Step 1: Google sign-in
      final account = await _googleService.signIn();
      if (account == null) {
        return const DataFailed(
          AuthException(
            message: 'Sign-in cancelled by user',
            code: 'popup-closed-by-user',
          ),
        );
      }

      // Step 2: Get tokens
      final googleAuth = await _googleService.getAuthentication(account);

      // Step 3: Build credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Step 4: Firebase sign-in
      final user = await _authService.signInWithCredential(credential);

      // Step 5: Upsert Firestore document
      final entity = AuthUserModel.fromRawData(user).toEntity();
      await _docService.upsertUser(entity);

      return DataSuccess(entity);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<DataState<void>> signOut() async {
    try {
      await _authService.signOut();
      // Safe no-op if the user was not signed in with Google
      await _googleService.signOut();
      return const DataSuccess(null);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<DataState<void>> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return const DataSuccess(null);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(UnknownException(message: e.toString()));
    }
  }

  @override
  Stream<AuthUserEntity?> watchAuthState() {
    return _authService.authStateChanges().map(
          (user) =>
              user != null ? AuthUserModel.fromRawData(user).toEntity() : null,
        );
  }

  @override
  AuthUserEntity? get currentUser {
    final user = _authService.currentUser;
    return user != null ? AuthUserModel.fromRawData(user).toEntity() : null;
  }

  @override
  Future<AuthUserEntity?> validateCachedUser() async {
    final user = await _authService.reloadCurrentUser();
    if (user == null) return null;
    return AuthUserModel.fromRawData(user).toEntity();
  }

  @override
  Future<DataState<AuthUserEntity>> linkAnonymousWithEmail(
    SignUpParams params,
  ) async {
    try {
      User linked;
      try {
        linked = await _authService.linkAnonymousWithEmailAndPassword(
          email: params.email,
          password: params.password,
        );
      } on AuthException catch (e) {
        if (e.code == 'email-already-in-use' ||
            e.code == 'credential-already-in-use') {
          // The anon session cannot be linked — sign out, sign in fresh with
          // the existing account so the user is left authenticated, then surface
          // a recoverable error so the UI can warn about anonymous data loss.
          await _authService.signOut();
          linked = await _authService.signInWithEmail(
            params.email,
            params.password,
          );
          final reloaded = _authService.currentUser ?? linked;
          final entity = AuthUserModel.fromRawData(reloaded).toEntity();
          await _docService.upsertUser(entity);
          return const DataFailed(AuthException(
            message:
                'Account merge required: previous anonymous data was not preserved.',
            code: 'merge-required',
          ));
        } else {
          rethrow;
        }
      }

      if (params.displayName.isNotEmpty) {
        linked = await _authService.updateDisplayName(linked, params.displayName);
      }

      final reloaded = _authService.currentUser ?? linked;
      final entity = AuthUserModel.fromRawData(reloaded).toEntity();
      await _docService.upsertUser(entity);
      return DataSuccess(entity);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<DataState<AuthUserEntity>> linkAnonymousWithGoogle() async {
    try {
      final account = await _googleService.signIn();
      if (account == null) {
        return const DataFailed(
          AuthException(message: 'Google sign-in cancelled', code: 'cancelled'),
        );
      }

      final googleAuth = await _googleService.getAuthentication(account);
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      User linked;
      try {
        linked = await _authService.linkAnonymousWithGoogleCredential(credential);
      } on AuthException catch (e) {
        if (e.code == 'email-already-in-use' ||
            e.code == 'credential-already-in-use') {
          // The anon session cannot be linked — sign out, sign in fresh with
          // the existing account so the user is left authenticated, then surface
          // a recoverable error so the UI can warn about anonymous data loss.
          await _authService.signOut();
          linked = await _authService.signInWithCredential(credential);
          final entity = AuthUserModel.fromRawData(linked).toEntity();
          await _docService.upsertUser(entity);
          return const DataFailed(AuthException(
            message:
                'Account merge required: previous anonymous data was not preserved.',
            code: 'merge-required',
          ));
        } else {
          rethrow;
        }
      }

      final entity = AuthUserModel.fromRawData(linked).toEntity();
      await _docService.upsertUser(entity);
      return DataSuccess(entity);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(UnknownException(message: e.toString()));
    }
  }
}
