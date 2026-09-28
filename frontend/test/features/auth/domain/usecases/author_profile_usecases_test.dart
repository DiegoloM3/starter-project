import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/user_profile_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_author_profile.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/update_user_profile.dart';

import 'author_profile_usecases_test.mocks.dart';

@GenerateMocks([UserProfileRepository, AuthRepository])
void main() {
  late MockUserProfileRepository mockRepository;
  late MockAuthRepository mockAuthRepository;

  const tProfile = UserProfileEntity(
    id: 'user-123',
    displayName: 'Jane Doe',
    photoUrl: 'https://example.com/avatar.jpg',
  );

  setUp(() {
    mockRepository = MockUserProfileRepository();
    mockAuthRepository = MockAuthRepository();
  });

  UpdateUserProfile buildUpdateUseCase() => UpdateUserProfile(
        mockAuthRepository,
        mockRepository,
      );

  group('GetAuthorProfile', () {
    test('should return the cached profile for the author', () async {
      when(mockRepository.getAuthorProfile('user-123'))
          .thenAnswer((_) async => const DataSuccess(tProfile));

      final result = await GetAuthorProfile(mockRepository)(
        params: const GetAuthorProfileParams(authorId: 'user-123'),
      );

      expect(result, isA<DataSuccess<UserProfileEntity?>>());
      expect(result.data, tProfile);
      verify(mockRepository.getAuthorProfile('user-123')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return null data when params are null', () async {
      final result = await GetAuthorProfile(mockRepository)();

      expect(result, isA<DataSuccess<UserProfileEntity?>>());
      expect(result.data, isNull);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('UpdateUserProfile', () {
    test('should upload once and mirror to auth before saving', () async {
      final avatar = File('path/to/avatar.png');
      when(mockRepository.uploadAvatar('user-123', avatar)).thenAnswer(
          (_) async => const DataSuccess('https://example.com/new.jpg'));
      when(mockAuthRepository.updateCurrentUserProfile(
        displayName: 'Jane',
        photoUrl: 'https://example.com/new.jpg',
      )).thenAnswer((_) async => const DataSuccess(null));
      when(mockRepository.updateUserProfile(
        userId: 'user-123',
        displayName: 'Jane',
        photoUrl: 'https://example.com/new.jpg',
      )).thenAnswer((_) async => const DataSuccess(tProfile));

      final result = await buildUpdateUseCase()(
        params: UpdateUserProfileParams(
          userId: 'user-123',
          displayName: 'Jane',
          avatarFile: avatar,
        ),
      );

      expect(result, isA<DataSuccess<UserProfileEntity>>());
      expect(result.data, tProfile);
      verify(mockRepository.uploadAvatar('user-123', avatar)).called(1);
      verify(mockAuthRepository.updateCurrentUserProfile(
        displayName: 'Jane',
        photoUrl: 'https://example.com/new.jpg',
      )).called(1);
      verify(mockRepository.updateUserProfile(
        userId: 'user-123',
        displayName: 'Jane',
        photoUrl: 'https://example.com/new.jpg',
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return DataGenericFailed when params are null', () async {
      final result = await buildUpdateUseCase()();

      expect(result, isA<DataGenericFailed<UserProfileEntity>>());
      verifyNoMoreInteractions(mockRepository);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should skip the firestore write when the auth mirror fails',
        () async {
      when(mockRepository.uploadAvatar('user-123', null))
          .thenAnswer((_) async => const DataSuccess(null));
      when(mockAuthRepository.updateCurrentUserProfile(
        displayName: anyNamed('displayName'),
        photoUrl: anyNamed('photoUrl'),
      )).thenAnswer(
          (_) async => const DataGenericFailed('Auth update failed'));

      final result = await buildUpdateUseCase()(
        params: const UpdateUserProfileParams(
          userId: 'user-123',
          displayName: 'Jane',
        ),
      );

      expect(result, isA<DataGenericFailed<UserProfileEntity>>());
      expect(result.errorMessage, contains('Auth update failed'));
      verifyNever(mockRepository.updateUserProfile(
        userId: anyNamed('userId'),
        displayName: anyNamed('displayName'),
        photoUrl: anyNamed('photoUrl'),
      ));
    });
  });
}
