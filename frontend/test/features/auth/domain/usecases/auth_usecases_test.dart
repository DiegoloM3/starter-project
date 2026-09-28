import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/user_profile_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/login_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/logout_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/register_usecase.dart';

import 'auth_usecases_test.mocks.dart';

@GenerateMocks([AuthRepository, UserProfileRepository])
void main() {
  late MockAuthRepository mockRepository;
  late MockUserProfileRepository mockProfileRepository;

  const tUser = UserEntity(
    id: 'user-123',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    mockProfileRepository = MockUserProfileRepository();
  });

  group('LoginUseCase', () {
    test('should call login on the repository and return DataSuccess', () async {
      when(mockRepository.login(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => const DataSuccess(tUser));

      final result = await LoginUseCase(mockRepository)(
        params: const LoginParams(
          email: 'test@example.com',
          password: 'password123',
        ),
      );

      expect(result, isA<DataSuccess<UserEntity>>());
      expect(result.data, tUser);
      verify(mockRepository.login(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('should return DataGenericFailed when params is null', () async {
      final result = await LoginUseCase(mockRepository)(params: null);

      expect(result, isA<DataGenericFailed<UserEntity>>());
      verifyZeroInteractions(mockRepository);
    });
  });

  group('RegisterUseCase', () {
    test('should register and create the public profile', () async {
      when(mockRepository.register(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      )).thenAnswer((_) async => const DataSuccess(tUser));
      when(mockProfileRepository.createUserProfile(any))
          .thenAnswer((_) async => const DataSuccess(null));

      final result = await RegisterUseCase(
        mockRepository,
        mockProfileRepository,
      )(
        params: const RegisterParams(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        ),
      );

      expect(result, isA<DataSuccess<UserEntity>>());
      expect(result.data, tUser);
      verify(mockRepository.register(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      )).called(1);
      final profile = verify(mockProfileRepository.createUserProfile(
        captureAny,
      )).captured.single as UserProfileEntity;
      expect(profile.id, 'user-123');
      expect(profile.displayName, 'Test User');
      verifyNever(mockRepository.deleteCurrentUser());
    });

    test('should delete the auth user when the profile write fails',
        () async {
      when(mockRepository.register(
        email: anyNamed('email'),
        password: anyNamed('password'),
        displayName: anyNamed('displayName'),
      )).thenAnswer((_) async => const DataSuccess(tUser));
      when(mockProfileRepository.createUserProfile(any))
          .thenAnswer(
              (_) async => const DataGenericFailed('Profile write failed'));
      when(mockRepository.deleteCurrentUser())
          .thenAnswer((_) async => const DataSuccess(null));

      final result = await RegisterUseCase(
        mockRepository,
        mockProfileRepository,
      )(
        params: const RegisterParams(
          email: 'test@example.com',
          password: 'password123',
        ),
      );

      expect(result, isA<DataGenericFailed<UserEntity>>());
      expect(result.errorMessage, contains('Profile write failed'));
      verify(mockRepository.deleteCurrentUser()).called(1);
    });

    test('should return DataGenericFailed when params is null', () async {
      final result = await RegisterUseCase(
        mockRepository,
        mockProfileRepository,
      )(params: null);

      expect(result, isA<DataGenericFailed<UserEntity>>());
      verifyZeroInteractions(mockRepository);
      verifyZeroInteractions(mockProfileRepository);
    });
  });

  group('LogoutUseCase', () {
    test('should call logout on the repository and return DataSuccess', () async {
      when(mockRepository.logout())
          .thenAnswer((_) async => const DataSuccess(null));

      final result = await LogoutUseCase(mockRepository)();

      expect(result, isA<DataSuccess<void>>());
      verify(mockRepository.logout()).called(1);
    });
  });

  group('GetCurrentUserUseCase', () {
    test('should call getCurrentUser on the repository and return user', () async {
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => const DataSuccess(tUser));

      final result = await GetCurrentUserUseCase(mockRepository)();

      expect(result, isA<DataSuccess<UserEntity?>>());
      expect(result.data, tUser);
      verify(mockRepository.getCurrentUser()).called(1);
    });
  });
}
