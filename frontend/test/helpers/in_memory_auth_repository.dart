import 'dart:async';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// [AuthRepository] that keeps accounts in memory for the current run.
///
/// It reproduces the provider's observable behaviour so every UI state can be
/// exercised: unknown email or wrong password fail with
/// [FailureType.invalidCredentials], a repeated sign-up fails with
/// [FailureType.emailAlreadyInUse], and Google sign-in always succeeds with a
/// fixed account.

class InMemoryAuthRepository implements AuthRepository {
  final Map<String, _Account> _accounts = {};
  final StreamController<UserEntity?> _controller =
      StreamController<UserEntity?>.broadcast();
  final Duration _latency;
  UserEntity? _currentUser;
  int _nextId = 1;

  static const UserEntity googleUser = UserEntity(
    id: 'google-uid',
    email: 'journalist@gmail.com',
    displayName: 'Google Journalist',
    photoUrl: 'https://picsum.photos/seed/avatar-google/200/200',
  );

  InMemoryAuthRepository({
    Duration latency = Duration.zero,
    UserEntity? initialUser,
  }) : _latency = latency {
    _currentUser = initialUser;
  }

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Stream<UserEntity?> watchAuthState() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<DataState<UserEntity>> signInWithEmail(SignInParams params) async {
    await _simulateLatency();
    final account = _accounts[params.trimmedEmail.toLowerCase()];
    if (account == null || account.password != params.password) {
      return const DataFailed(Failure.invalidCredentials());
    }
    _setCurrentUser(account.user);
    return DataSuccess(account.user);
  }

  @override
  Future<DataState<UserEntity>> signUpWithEmail(SignUpParams params) async {
    await _simulateLatency();
    final key = params.trimmedEmail.toLowerCase();
    if (_accounts.containsKey(key)) {
      return const DataFailed(Failure.emailAlreadyInUse());
    }
    final user = UserEntity(
      id: 'local-uid-${_nextId++}',
      email: params.trimmedEmail,
      displayName: params.trimmedDisplayName,
    );
    _accounts[key] = _Account(user: user, password: params.password);
    _setCurrentUser(user);
    return DataSuccess(user);
  }

  @override
  Future<DataState<UserEntity>> signInWithGoogle() async {
    await _simulateLatency();
    _setCurrentUser(googleUser);
    return const DataSuccess(googleUser);
  }

  @override
  Future<DataState<UserEntity>> updateProfile({String? displayName, String? photoUrl}) async {
    await _simulateLatency();
    final user = _currentUser;
    if (user == null) return const DataFailed(Failure.unauthenticated());
    final updated = user.copyWith(displayName: displayName, photoUrl: photoUrl);
    final key = user.email?.toLowerCase();
    final account = key == null ? null : _accounts[key];
    if (account != null) _accounts[key!] = _Account(user: updated, password: account.password);
    _setCurrentUser(updated);
    return DataSuccess(updated);
  }

  @override
  Future<DataState<void>> signOut() async {
    await _simulateLatency();
    _setCurrentUser(null);
    return const DataSuccess(null);
  }

  void _setCurrentUser(UserEntity? user) {
    _currentUser = user;
    _controller.add(user);
  }

  Future<void> _simulateLatency() {
    return _latency == Duration.zero ? Future.value() : Future.delayed(_latency);
  }

  /// Releases the auth-state stream. Call when the repository is discarded.
  Future<void> dispose() => _controller.close();
}

class _Account {
  final UserEntity user;
  final String password;

  const _Account({required this.user, required this.password});
}
