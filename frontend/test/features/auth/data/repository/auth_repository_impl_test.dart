import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:tortutip/features/auth/data/repository/auth_repository_impl.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  final tUser = UserEntity(
    id: 'user_1',
    name: 'Test User',
    email: 'test@example.com',
    avatarUrl: '',
    bio: '',
    role: 'reader',
    gender: '',
    ageRange: '',
    createdAt: DateTime(2024),
  );

  group('AuthRepositoryImpl.signInWithGoogle', () {
    test('should_return_DataSuccess_when_datasource_succeeds', () async {
      when(() => mockDataSource.signInWithGoogle())
          .thenAnswer((_) async => tUser);

      final result = await repository.signInWithGoogle();

      expect(result, isA<DataSuccess<UserEntity>>());
      expect(result.data, equals(tUser));
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.signInWithGoogle())
          .thenThrow(Exception('Firestore error'));

      final result = await repository.signInWithGoogle();

      expect(result, isA<DataFailed<UserEntity>>());
    });
  });

  group('AuthRepositoryImpl.signOut', () {
    test('should_return_DataSuccess_when_datasource_succeeds', () async {
      when(() => mockDataSource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, isA<DataSuccess<bool>>());
      expect(result.data, isTrue);
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.signOut())
          .thenThrow(Exception('Sign out error'));

      final result = await repository.signOut();

      expect(result, isA<DataFailed<bool>>());
    });
  });

  group('AuthRepositoryImpl.checkCurrentAuth', () {
    test('should_return_DataSuccess_with_user_when_datasource_returns_user',
        () async {
      when(() => mockDataSource.checkCurrentUser())
          .thenAnswer((_) async => tUser);

      final result = await repository.checkCurrentAuth();

      expect(result, isA<DataSuccess<UserEntity>>());
      expect(result.data, equals(tUser));
    });

    test('should_return_DataFailed_when_datasource_returns_null', () async {
      when(() => mockDataSource.checkCurrentUser())
          .thenAnswer((_) async => null);

      final result = await repository.checkCurrentAuth();

      expect(result, isA<DataFailed<UserEntity>>());
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.checkCurrentUser())
          .thenThrow(Exception('Auth error'));

      final result = await repository.checkCurrentAuth();

      expect(result, isA<DataFailed<UserEntity?>>());
    });
  });
}
