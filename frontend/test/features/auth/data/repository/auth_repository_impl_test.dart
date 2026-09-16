import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user_model.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

void main() {
  late MockFirebaseAuthService service;
  late AuthRepositoryImpl repository;
  const model = UserModel(id: 'uid-1', email: 'ada@example.com', displayName: 'Ada');

  setUp(() {
    service = MockFirebaseAuthService();
    repository = AuthRepositoryImpl(service);
  });

  test('watchAuthState and currentUser expose entities, not models', () async {
    when(service.authStateChanges).thenAnswer((_) => Stream.fromIterable([null, model]));
    when(() => service.currentUser).thenReturn(model);

    expect(await repository.watchAuthState().toList(), [null, model.toEntity()]);
    expect(repository.currentUser?.id, 'uid-1');
  });

  test('signInWithEmail trims the email and maps a wrong password', () async {
    when(() => service.signInWithEmail(email: 'ada@example.com', password: 'pw'))
        .thenAnswer((_) async => model);
    final ok = await repository.signInWithEmail(const SignInParams(email: ' ada@example.com ', password: 'pw'));
    expect(ok.dataOrNull?.email, 'ada@example.com');

    when(() => service.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(FirebaseAuthException(code: 'wrong-password'));
    final failed = await repository.signInWithEmail(const SignInParams(email: 'a@b.co', password: 'x'));
    expect(failed.failureOrNull?.type, FailureType.invalidCredentials);
  });

  test('signUpWithEmail passes the display name and maps a taken email', () async {
    when(() => service.signUpWithEmail(
          displayName: 'Ada',
          email: 'ada@example.com',
          password: 'secret123',
        )).thenAnswer((_) async => model);
    final ok = await repository.signUpWithEmail(
      const SignUpParams(displayName: ' Ada ', email: 'ada@example.com', password: 'secret123'),
    );
    expect(ok.isSuccess, isTrue);

    when(() => service.signUpWithEmail(
          displayName: any(named: 'displayName'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
    final failed = await repository.signUpWithEmail(
      const SignUpParams(displayName: 'Ada', email: 'ada@example.com', password: 'secret123'),
    );
    expect(failed.failureOrNull?.type, FailureType.emailAlreadyInUse);
  });

  test('signInWithGoogle succeeds and network problems are reported', () async {
    when(service.signInWithGoogle).thenAnswer((_) async => model);
    expect((await repository.signInWithGoogle()).isSuccess, isTrue);

    when(service.signInWithGoogle).thenThrow(FirebaseAuthException(code: 'network-request-failed'));
    expect((await repository.signInWithGoogle()).failureOrNull?.type, FailureType.network);
  });

  test('signOut delegates', () async {
    when(service.signOut).thenAnswer((_) async {});
    expect((await repository.signOut()).isSuccess, isTrue);
    verify(service.signOut).called(1);
  });

  test('updateProfile returns the refreshed account as an entity', () async {
    when(() => service.updateProfile(displayName: 'Grace', photoUrl: null))
        .thenAnswer((_) async => const UserModel(id: 'uid-1', displayName: 'Grace'));

    final result = await repository.updateProfile(displayName: 'Grace');

    expect(result.dataOrNull?.displayName, 'Grace');
  });
}
