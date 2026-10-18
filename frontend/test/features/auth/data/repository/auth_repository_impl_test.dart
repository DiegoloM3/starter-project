import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:news_app_clean_architecture/shared/users/data/data_sources/remote/user_profile_remote_data_source.dart';
import 'package:news_app_clean_architecture/shared/users/data/models/user_model.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/shared/users/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockUserProfileRemoteDataSource extends Mock implements UserProfileRemoteDataSource {}

const profile = UserModel(uid: 'user-1', firstName: 'Jane', lastName: 'Doe', bio: '', role: UserRole.reader);

void main() {
  late MockAuthRemoteDataSource authDataSource;
  late MockUserProfileRemoteDataSource profileDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    authDataSource = MockAuthRemoteDataSource();
    profileDataSource = MockUserProfileRemoteDataSource();
    repository = AuthRepositoryImpl(authDataSource, profileDataSource);
  });

  group('signUp', () {
    final params = SignUpParams(firstName: 'Jane', lastName: 'Doe', email: 'Jane@Test.com', password: 'password123');

    void stubAccountCreation() {
      when(
        () => authDataSource.createAccount(email: params.email, password: params.password),
      ).thenAnswer((_) async => (uid: 'user-1', email: 'jane@test.com'));
    }

    test('creates the account and a reader profile with the email of the account', () async {
      stubAccountCreation();
      when(
        () =>
            profileDataSource.createProfile(uid: 'user-1', firstName: 'Jane', lastName: 'Doe', email: 'jane@test.com'),
      ).thenAnswer((_) async {});

      final result = await repository.signUp(params);

      expect(result.data, profile.toEntity());
    });

    test('deletes the new account when its profile cannot be created', () async {
      final error = Exception('offline');
      stubAccountCreation();
      when(
        () => profileDataSource.createProfile(
          uid: any(named: 'uid'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          email: any(named: 'email'),
        ),
      ).thenThrow(error);
      when(() => authDataSource.deleteSignedInAccount()).thenAnswer((_) async {});

      final result = await repository.signUp(params);

      expect(result.error, error);
      verify(() => authDataSource.deleteSignedInAccount()).called(1);
    });
  });

  group('signIn', () {
    final params = SignInParams(email: 'jane@test.com', password: 'password');

    test('signs in and returns the profile', () async {
      when(
        () => authDataSource.signIn(email: params.email, password: params.password),
      ).thenAnswer((_) async => 'user-1');
      when(() => profileDataSource.getProfile('user-1')).thenAnswer((_) async => profile);

      final result = await repository.signIn(params);

      expect(result.data, profile.toEntity());
    });

    test('fails with the exception of the data source', () async {
      when(
        () => authDataSource.signIn(email: params.email, password: params.password),
      ).thenThrow(const InvalidCredentialsException());

      final result = await repository.signIn(params);

      expect(result.error, isA<InvalidCredentialsException>());
    });
  });

  test('signs out', () async {
    when(() => authDataSource.signOut()).thenAnswer((_) async {});

    final result = await repository.signOut();

    expect(result, isA<DataSuccess>());
  });

  group('deleteAccount', () {
    setUp(() {
      when(() => authDataSource.signedInUserId).thenReturn('user-1');
      when(() => authDataSource.reauthenticate('password')).thenAnswer((_) async {});
      when(() => profileDataSource.deleteUserData('user-1')).thenAnswer((_) async {});
      when(() => authDataSource.deleteSignedInAccount()).thenAnswer((_) async {});
    });

    test('confirms the password, deletes the data of the user and then the account', () async {
      final result = await repository.deleteAccount('password');

      expect(result, isA<DataSuccess>());
      verifyInOrder([
        () => authDataSource.reauthenticate('password'),
        () => profileDataSource.deleteUserData('user-1'),
        () => authDataSource.deleteSignedInAccount(),
      ]);
    });

    test('keeps everything when the password is wrong', () async {
      when(() => authDataSource.reauthenticate('password')).thenThrow(const InvalidCredentialsException());

      final result = await repository.deleteAccount('password');

      expect(result.error, isA<InvalidCredentialsException>());
      verifyNever(() => profileDataSource.deleteUserData(any()));
      verifyNever(() => authDataSource.deleteSignedInAccount());
    });
  });

  group('watchCurrentUser', () {
    late StreamController<String?> signedInUserIds;
    late StreamController<UserModel?> profiles;

    setUp(() {
      signedInUserIds = StreamController();
      profiles = StreamController();
      when(() => authDataSource.watchSignedInUserId()).thenAnswer((_) => signedInUserIds.stream);
      when(() => profileDataSource.watchProfile('user-1')).thenAnswer((_) => profiles.stream);
    });

    tearDown(() {
      signedInUserIds.close();
      profiles.close();
    });

    test('emits the profile of the signed in user and null when they sign out', () async {
      final users = repository.watchCurrentUser();
      final expectation = expectLater(users, emitsInOrder([null, profile.toEntity(), null]));

      signedInUserIds.add(null);
      await pumpEventQueue();
      signedInUserIds.add('user-1');
      await pumpEventQueue();
      profiles.add(profile);
      await pumpEventQueue();
      signedInUserIds.add(null);

      await expectation;
    });

    test('waits until the profile of a new account exists', () async {
      final users = repository.watchCurrentUser();
      final expectation = expectLater(users, emits(profile.toEntity()));

      signedInUserIds.add('user-1');
      await pumpEventQueue();
      profiles.add(null);
      profiles.add(profile);

      await expectation;
    });
  });
}
