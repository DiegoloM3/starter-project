import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockFirebaseAuthDataSource mockDataSource;
  late MockUser mockUser;

  setUp(() {
    mockDataSource = MockFirebaseAuthDataSource();
    mockUser = MockUser();
    repository = AuthRepositoryImpl(mockDataSource);

    when(() => mockUser.uid).thenReturn(tUserId);
    when(() => mockUser.email).thenReturn(tEmail);
    when(() => mockUser.displayName).thenReturn(tAuthorName);
  });

  group('signIn', () {
    test('returns DataSuccess with mapped AuthUserEntity', () async {
      when(() => mockDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockUser);

      final result = await repository.signIn(
        email: tEmail,
        password: tPassword,
      );

      expect(result, isA<DataSuccess>());
      expect(result.data!.uid, tUserId);
      expect(result.data!.email, tEmail);
    });

    test('returns DataFailed with user-not-found message', () async {
      when(() => mockDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(
        code: 'user-not-found',
        message: 'Not found',
      ));

      final result = await repository.signIn(
        email: tEmail,
        password: tPassword,
      );

      expect(result, isA<DataFailed>());
      expect(result.error, isA<AuthException>());
      expect(result.error!.code, 'user-not-found');
      expect(result.error!.message, 'No account found with this email');
    });

    test('returns DataFailed with wrong-password message', () async {
      when(() => mockDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(
        code: 'wrong-password',
        message: 'Wrong',
      ));

      final result = await repository.signIn(
        email: tEmail,
        password: tPassword,
      );

      expect(result, isA<DataFailed>());
      expect(result.error!.message, 'Incorrect password');
    });

    test('returns DataFailed with invalid-credential message', () async {
      when(() => mockDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(
        code: 'invalid-credential',
        message: 'Invalid',
      ));

      final result = await repository.signIn(
        email: tEmail,
        password: tPassword,
      );

      expect(result, isA<DataFailed>());
      expect(result.error!.message, 'Invalid email or password');
    });
  });

  group('signUp', () {
    test('returns DataSuccess with new AuthUserEntity', () async {
      when(() => mockDataSource.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockUser);

      final result = await repository.signUp(
        email: tEmail,
        password: tPassword,
      );

      expect(result, isA<DataSuccess>());
      expect(result.data!.uid, tUserId);
    });

    test('returns DataFailed on email-already-in-use', () async {
      when(() => mockDataSource.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'Exists',
      ));

      final result = await repository.signUp(
        email: tEmail,
        password: tPassword,
      );

      expect(result, isA<DataFailed>());
      expect(result.error!.message, 'An account already exists with this email');
    });

    test('returns DataFailed on weak-password', () async {
      when(() => mockDataSource.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(
        code: 'weak-password',
        message: 'Weak',
      ));

      final result = await repository.signUp(
        email: tEmail,
        password: tPassword,
      );

      expect(result, isA<DataFailed>());
      expect(result.error!.message, 'Password must be at least 6 characters');
    });
  });

  group('signOut', () {
    test('returns DataSuccess on success', () async {
      when(() => mockDataSource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, isA<DataSuccess>());
    });

    test('returns DataFailed on FirebaseException', () async {
      when(() => mockDataSource.signOut())
          .thenThrow(FirebaseException(
        plugin: 'auth',
        code: 'unknown',
        message: 'Sign out failed',
      ));

      final result = await repository.signOut();

      expect(result, isA<DataFailed>());
    });
  });

  group('authStateChanges', () {
    test('maps User to AuthUserEntity', () async {
      when(() => mockDataSource.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));

      final stream = repository.authStateChanges;
      final entity = await stream.first;

      expect(entity, isNotNull);
      expect(entity!.uid, tUserId);
    });

    test('maps null to null', () async {
      when(() => mockDataSource.authStateChanges)
          .thenAnswer((_) => Stream.value(null));

      final stream = repository.authStateChanges;

      await expectLater(stream, emits(isNull));
    });
  });

  group('currentUser', () {
    test('returns mapped entity when user exists', () {
      when(() => mockDataSource.currentUser).thenReturn(mockUser);

      final result = repository.currentUser;

      expect(result, isNotNull);
      expect(result!.uid, tUserId);
    });

    test('returns null when no current user', () {
      when(() => mockDataSource.currentUser).thenReturn(null);

      final result = repository.currentUser;

      expect(result, isNull);
    });
  });
}
