import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/shared/user/data/data_sources/user_remote_data_source.dart';
import 'package:tortutip/shared/user/data/models/user_model.dart';
import 'package:tortutip/shared/user/data/repository/user_repository_impl.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class MockUserRemoteDataSource extends Mock implements UserRemoteDataSource {}

void main() {
  late UserRepositoryImpl repository;
  late MockUserRemoteDataSource mockDataSource;

  final userModel = UserModel(
    id: 'user_1',
    name: 'Test',
    email: 'test@test.com',
    avatarUrl: '',
    bio: '',
    role: 'reader',
    gender: '',
    ageRange: '',
    createdAt: DateTime(2024),
    streakDays: 0,
    lastFeedDate: '',
    overallProgress: 0.0,
  );

  setUp(() {
    mockDataSource = MockUserRemoteDataSource();
    repository = UserRepositoryImpl(mockDataSource);
    registerFallbackValue(userModel);
  });

  group('UserRepositoryImpl.getCurrentUser', () {
    test('should_return_DataSuccess_with_entity_when_datasource_succeeds',
        () async {
      when(() => mockDataSource.getCurrentUser())
          .thenAnswer((_) async => userModel);

      final result = await repository.getCurrentUser();

      expect(result, isA<DataSuccess<UserEntity>>());
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.getCurrentUser())
          .thenThrow(Exception('No hay usuario autenticado'));

      final result = await repository.getCurrentUser();

      expect(result, isA<DataFailed<UserEntity>>());
    });
  });

  group('UserRepositoryImpl.updateUserRole', () {
    test('should_return_DataSuccess_when_datasource_succeeds', () async {
      when(() => mockDataSource.updateUserRole(any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.updateUserRole('user_1', 'writer');

      expect(result, isA<DataSuccess<bool>>());
      expect(result.data, isTrue);
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.updateUserRole(any(), any()))
          .thenThrow(Exception('error'));

      final result = await repository.updateUserRole('user_1', 'writer');

      expect(result, isA<DataFailed<bool>>());
    });
  });

  group('UserRepositoryImpl.selectUserCategories', () {
    test('should_return_DataSuccess_when_datasource_succeeds', () async {
      when(() => mockDataSource.selectUserCategories(any(), any()))
          .thenAnswer((_) async {});

      final result =
          await repository.selectUserCategories('user_1', ['cat_1']);

      expect(result, isA<DataSuccess<bool>>());
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.selectUserCategories(any(), any()))
          .thenThrow(Exception('error'));

      final result =
          await repository.selectUserCategories('user_1', ['cat_1']);

      expect(result, isA<DataFailed<bool>>());
    });
  });

  group('UserRepositoryImpl.updateUserProfile', () {
    test('should_return_DataSuccess_with_entity_when_datasource_succeeds',
        () async {
      when(() => mockDataSource.updateUserProfile(any()))
          .thenAnswer((_) async => userModel);

      final result = await repository.updateUserProfile(userModel);

      expect(result, isA<DataSuccess<UserEntity>>());
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.updateUserProfile(any()))
          .thenThrow(Exception('error'));

      final result = await repository.updateUserProfile(userModel);

      expect(result, isA<DataFailed<UserEntity>>());
    });
  });

  group('UserRepositoryImpl.getUserById', () {
    test('should_return_DataSuccess_with_user_when_getUserById_datasource_succeeds',
        () async {
      when(() => mockDataSource.getUserById(any()))
          .thenAnswer((_) async => userModel);

      final result = await repository.getUserById('user_1');

      expect(result, isA<DataSuccess<UserEntity>>());
    });

    test('should_return_DataFailed_when_getUserById_datasource_throws', () async {
      when(() => mockDataSource.getUserById(any()))
          .thenThrow(Exception('not found'));

      final result = await repository.getUserById('user_1');

      expect(result, isA<DataFailed<UserEntity>>());
    });
  });

  group('UserRepositoryImpl.recordFeedSwipe', () {
    test('should_return_DataSuccess_with_entity_when_datasource_succeeds',
        () async {
      when(() => mockDataSource.recordFeedSwipe(any()))
          .thenAnswer((_) async => userModel);

      final result = await repository.recordFeedSwipe('user_1');

      expect(result, isA<DataSuccess<UserEntity>>());
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.recordFeedSwipe(any()))
          .thenThrow(Exception('Firestore error'));

      final result = await repository.recordFeedSwipe('user_1');

      expect(result, isA<DataFailed<UserEntity>>());
    });
  });
}
