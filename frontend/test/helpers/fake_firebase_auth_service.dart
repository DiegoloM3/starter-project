import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';
import 'package:news_app_clean_architecture/features/authentication/data/data_sources/remote/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/authentication/data/models/app_user_model.dart';

/// Stand in for the one class that talks to Firebase Authentication.
///
/// It needs nothing of the Firebase SDK any more: since the service returns
/// models and throws [RemoteException], faking it is faking plain Dart. That
/// is the point of rule 1.2.4 showing up in a test.
class FakeFirebaseAuthService implements FirebaseAuthService {
  Object? errorToThrow;

  AppUserModel? user = anyUser;

  String? lastDisplayNameWritten;
  String? lastPasswordResetEmail;
  int signOutCallCount = 0;

  static const AppUserModel anyUser = AppUserModel(
    id: 'user-1',
    email: 'alex@example.com',
    displayName: 'Alex Rivera',
  );

  @override
  AppUserModel? get currentUser => user;

  void _throwIfArmed() {
    final error = errorToThrow;

    if (error != null) {
      throw error;
    }
  }

  AppUserModel _answer() {
    _throwIfArmed();

    return user!;
  }

  @override
  Future<AppUserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return _answer();
  }

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    return _answer();
  }

  @override
  Future<AppUserModel> updateDisplayName(String displayName) async {
    final answer = _answer();
    lastDisplayNameWritten = displayName;

    return answer;
  }

  @override
  Future<void> signOut() async {
    _throwIfArmed();
    signOutCallCount++;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    _throwIfArmed();
    lastPasswordResetEmail = email;
  }

  /// Anything the real service grows later fails loudly here rather than
  /// quietly returning null and making a test pass for the wrong reason.
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        '${invocation.memberName} is not faked by FakeFirebaseAuthService',
      );
}

/// The data layer's error, carrying the code Firebase would have given.
RemoteException authError(String code) => RemoteException(code);
