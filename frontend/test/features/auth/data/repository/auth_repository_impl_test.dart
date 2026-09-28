import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/auth_firebase_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user.model.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AuthFirebaseService>()])
void main() {
  late MockAuthFirebaseService mockFirebaseService;
  late AuthRepositoryImpl repository;

  const tUserModel = UserModel(
    id: 'uid-123',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  setUp(() {
    mockFirebaseService = MockAuthFirebaseService();
    repository = AuthRepositoryImpl(mockFirebaseService);
  });

  group('login', () {
    test('should return DataSuccess with UserModel on success', () async {
      when(mockFirebaseService.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => tUserModel);

      final result = await repository.login(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<DataSuccess<UserEntity>>());
      expect(result.data, tUserModel);
      verify(mockFirebaseService.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('should return DataGenericFailed on failure', () async {
      when(mockFirebaseService.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'wrong',
      )).thenThrow('Invalid credentials');

      final result = await repository.login(
        email: 'test@example.com',
        password: 'wrong',
      );

      expect(result, isA<DataGenericFailed<UserEntity>>());
      expect(result.errorMessage, contains('Invalid credentials'));
    });
  });

  group('register', () {
    test('should return DataSuccess with UserModel on success', () async {
      when(mockFirebaseService.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      )).thenAnswer((_) async => tUserModel);

      final result = await repository.register(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      );

      expect(result, isA<DataSuccess<UserEntity>>());
      expect(result.data, tUserModel);
      verify(mockFirebaseService.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      )).called(1);
    });

    test('should return DataGenericFailed on failure', () async {
      when(mockFirebaseService.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'short',
        displayName: null,
      )).thenThrow('Weak password');

      final result = await repository.register(
        email: 'test@example.com',
        password: 'short',
      );

      expect(result, isA<DataGenericFailed<UserEntity>>());
      expect(result.errorMessage, contains('Weak password'));
    });
  });

  group('logout', () {
    test('should call signOut and return DataSuccess', () async {
      when(mockFirebaseService.signOut()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result, isA<DataSuccess<void>>());
      verify(mockFirebaseService.signOut()).called(1);
    });
  });

  group('getCurrentUser', () {
    test('should return current user in DataSuccess', () async {
      when(mockFirebaseService.currentUser).thenReturn(tUserModel);

      final result = await repository.getCurrentUser();

      expect(result, isA<DataSuccess<UserEntity?>>());
      expect(result.data, tUserModel);
    });
  });

  group('updateCurrentUserProfile', () {
    test('should mirror name and photo onto the auth user', () async {
      when(mockFirebaseService.updateAuthProfile(
        displayName: 'Jane',
        photoUrl: 'https://example.com/new.jpg',
      )).thenAnswer((_) async => tUserModel);

      final result = await repository.updateCurrentUserProfile(
        displayName: 'Jane',
        photoUrl: 'https://example.com/new.jpg',
      );

      expect(result, isA<DataSuccess<UserEntity?>>());
      expect(result.data, tUserModel);
      verify(mockFirebaseService.updateAuthProfile(
        displayName: 'Jane',
        photoUrl: 'https://example.com/new.jpg',
      )).called(1);
    });

    test('should return DataGenericFailed when the service throws', () async {
      when(mockFirebaseService.updateAuthProfile(
        displayName: anyNamed('displayName'),
        photoUrl: anyNamed('photoUrl'),
      )).thenThrow(Exception('Auth update failed'));

      final result = await repository.updateCurrentUserProfile(
        displayName: 'Jane',
      );

      expect(result, isA<DataGenericFailed<UserEntity?>>());
      expect(result.errorMessage, contains('Auth update failed'));
    });
  });
}
