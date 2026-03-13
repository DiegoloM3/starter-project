import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user_model.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  final testUserModel = UserModel(
    id: 'user123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: 'https://example.com/photo.jpg',
    createdAt: DateTime(2024, 1, 1),
  );

  group('signIn', () {
    test('should return DataSuccess with user when data source succeeds',
        () async {
      // Arrange
      when(mockDataSource.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, testUserModel);
      verify(mockDataSource.signIn(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('should return DataFailed when data source throws exception',
        () async {
      // Arrange
      when(mockDataSource.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(Exception('User not found'));

      // Act
      final result = await repository.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result, isA<DataFailed>());
      expect((result as DataFailed).exception, isA<Exception>());
    });
  });

  group('signUp', () {
    test('should return DataSuccess with user when data source succeeds',
        () async {
      // Arrange
      when(mockDataSource.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        displayName: anyNamed('displayName'),
      )).thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.signUp(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      );

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, testUserModel);
      verify(mockDataSource.signUp(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      )).called(1);
    });

    test('should return DataFailed when data source throws exception',
        () async {
      // Arrange
      when(mockDataSource.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        displayName: anyNamed('displayName'),
      )).thenThrow(Exception('Email already exists'));

      // Act
      final result = await repository.signUp(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      );

      // Assert
      expect(result, isA<DataFailed>());
    });
  });

  group('signOut', () {
    test('should complete when data source succeeds', () async {
      // Arrange
      when(mockDataSource.signOut()).thenAnswer((_) async {});

      // Act & Assert - should complete without throwing
      await expectLater(repository.signOut(), completes);
      verify(mockDataSource.signOut()).called(1);
    });

    test('should throw when data source throws', () async {
      // Arrange
      when(mockDataSource.signOut()).thenThrow(Exception('Sign out failed'));

      // Act & Assert
      expect(() => repository.signOut(), throwsException);
    });
  });

  group('getCurrentUser', () {
    test('should return user when data source returns user', () async {
      // Arrange
      when(mockDataSource.getCurrentUser())
          .thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, testUserModel);
      verify(mockDataSource.getCurrentUser()).called(1);
    });

    test('should return null when no user is logged in', () async {
      // Arrange
      when(mockDataSource.getCurrentUser()).thenAnswer((_) async => null);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, isNull);
    });

    test('should throw when data source throws', () async {
      // Arrange
      when(mockDataSource.getCurrentUser())
          .thenThrow(Exception('Error getting user'));

      // Act & Assert
      expect(() => repository.getCurrentUser(), throwsException);
    });
  });

  group('authStateChanges', () {
    test('should return stream from data source', () {
      // Arrange
      final userStream = Stream<UserModel?>.fromIterable([testUserModel, null]);
      when(mockDataSource.authStateChanges).thenAnswer((_) => userStream);

      // Act
      final result = repository.authStateChanges;

      // Assert
      expect(result, isA<Stream>());
      verify(mockDataSource.authStateChanges).called(1);
    });

    test('should emit user when data source emits user', () async {
      // Arrange
      final userStream = Stream<UserModel?>.fromIterable([testUserModel]);
      when(mockDataSource.authStateChanges).thenAnswer((_) => userStream);

      // Act
      final result = repository.authStateChanges;

      // Assert
      await expectLater(result, emits(testUserModel));
    });

    test('should emit null when data source emits null', () async {
      // Arrange
      final userStream = Stream<UserModel?>.fromIterable([null]);
      when(mockDataSource.authStateChanges).thenAnswer((_) => userStream);

      // Act
      final result = repository.authStateChanges;

      // Assert
      await expectLater(result, emits(null));
    });
  });

  group('updateProfile', () {
    test('should return DataSuccess when data source succeeds', () async {
      // Arrange
      when(mockDataSource.getCurrentUser())
          .thenAnswer((_) async => testUserModel);
      final updatedUser = testUserModel.copyWith(displayName: 'Updated Name');
      when(mockDataSource.updateProfile(
        userId: anyNamed('userId'),
        displayName: anyNamed('displayName'),
        photoUrl: anyNamed('photoUrl'),
      )).thenAnswer((_) async => updatedUser);

      // Act
      final result = await repository.updateProfile(
        displayName: 'Updated Name',
      );

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data.displayName, 'Updated Name');
    });

    test('should update all profile fields when provided', () async {
      // Arrange
      when(mockDataSource.getCurrentUser())
          .thenAnswer((_) async => testUserModel);
      final updatedUser = testUserModel.copyWith(
        displayName: 'New Name',
        photoUrl: 'https://new.com/photo.jpg',
      );
      when(mockDataSource.updateProfile(
        userId: anyNamed('userId'),
        displayName: anyNamed('displayName'),
        photoUrl: anyNamed('photoUrl'),
      )).thenAnswer((_) async => updatedUser);

      // Act
      final result = await repository.updateProfile(
        displayName: 'New Name',
        photoUrl: 'https://new.com/photo.jpg',
      );

      // Assert
      expect(result, isA<DataSuccess>());
    });

    test('should return DataFailed when no current user', () async {
      // Arrange
      when(mockDataSource.getCurrentUser()).thenAnswer((_) async => null);

      // Act
      final result = await repository.updateProfile(displayName: 'New Name');

      // Assert
      expect(result, isA<DataFailed>());
    });

    test('should return DataFailed when data source throws', () async {
      // Arrange
      when(mockDataSource.getCurrentUser())
          .thenAnswer((_) async => testUserModel);
      when(mockDataSource.updateProfile(
        userId: anyNamed('userId'),
        displayName: anyNamed('displayName'),
        photoUrl: anyNamed('photoUrl'),
      )).thenThrow(Exception('Update failed'));

      // Act
      final result = await repository.updateProfile(displayName: 'New Name');

      // Assert
      expect(result, isA<DataFailed>());
    });
  });
}
