import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';

class FakeAuthRepository implements AuthRepository {
  AuthUser? currentUser;
  String? lastSignInEmail;
  String? lastSignInPassword;
  bool signOutCalled = false;

  @override
  Future<AuthUser?> getCurrentUser() async => currentUser;

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    lastSignInEmail = email;
    lastSignInPassword = password;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}

void main() {
  group('Auth use cases', () {
    late FakeAuthRepository repository;

    setUp(() {
      repository = FakeAuthRepository();
    });

    test('GetCurrentUserUseCase returns current user', () async {
      const expected = AuthUser(uid: 'uid-1', email: 'user@test.com');
      repository.currentUser = expected;
      final useCase = GetCurrentUserUseCase(repository);

      final result = await useCase();

      expect(result, equals(expected));
    });

    test('SignInUseCase forwards email and password', () async {
      final useCase = SignInUseCase(repository);

      await useCase(params: SignInParams('user@test.com', 'secret123'));

      expect(repository.lastSignInEmail, 'user@test.com');
      expect(repository.lastSignInPassword, 'secret123');
    });

    test('SignOutUseCase calls repository signOut', () async {
      final useCase = SignOutUseCase(repository);

      await useCase();

      expect(repository.signOutCalled, isTrue);
    });
  });
}
