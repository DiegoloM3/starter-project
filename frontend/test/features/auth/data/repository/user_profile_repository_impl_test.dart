import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/user_profile_firebase_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user_profile.model.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/user_profile_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';

import 'user_profile_repository_impl_test.mocks.dart';

@GenerateMocks([UserProfileFirebaseService])
void main() {
  late MockUserProfileFirebaseService mockService;
  late UserProfileRepositoryImpl repository;

  const tProfile = UserProfileModel(
    id: 'user-123',
    displayName: 'Jane Doe',
    photoUrl: 'https://example.com/avatar.jpg',
  );

  setUp(() {
    mockService = MockUserProfileFirebaseService();
    repository = UserProfileRepositoryImpl(mockService);
  });

  group('createUserProfile', () {
    test('should create the profile and prime the cache', () async {
      when(mockService.createUserProfile(any)).thenAnswer((_) async {});

      final result = await repository.createUserProfile(tProfile);

      expect(result, isA<DataSuccess<void>>());
      verify(mockService.createUserProfile(argThat(
        isA<UserProfileModel>()
            .having((p) => p.id, 'id', 'user-123')
            .having((p) => p.displayName, 'displayName', 'Jane Doe'),
      ))).called(1);

      // Primed: the next read must not hit the service again.
      final cached = await repository.getAuthorProfile('user-123');
      expect((cached as DataSuccess).data, tProfile);
      verifyNoMoreInteractions(mockService);
    });

    test('should return DataGenericFailed when the service throws', () async {
      when(mockService.createUserProfile(any))
          .thenThrow(Exception('Firestore write failed'));

      final result = await repository.createUserProfile(tProfile);

      expect(result, isA<DataGenericFailed<void>>());
      expect(result.errorMessage, contains('Firestore write failed'));
    });
  });

  group('getAuthorProfile cache', () {
    test('should hit the service once for repeated reads', () async {
      when(mockService.getUserProfile('user-123'))
          .thenAnswer((_) async => tProfile);

      final first = await repository.getAuthorProfile('user-123');
      final second = await repository.getAuthorProfile('user-123');

      expect((first as DataSuccess).data, tProfile);
      expect((second as DataSuccess).data, tProfile);
      verify(mockService.getUserProfile('user-123')).called(1);
    });

    test('should return null data when the profile does not exist', () async {
      when(mockService.getUserProfile('ghost'))
          .thenAnswer((_) async => null);

      final result = await repository.getAuthorProfile('ghost');

      expect(result, isA<DataSuccess<UserProfileEntity?>>());
      expect(result.data, isNull);
    });

    test('should re-read after invalidateAuthorProfile', () async {
      when(mockService.getUserProfile('user-123'))
          .thenAnswer((_) async => tProfile);

      await repository.getAuthorProfile('user-123');
      repository.invalidateAuthorProfile('user-123');
      await repository.getAuthorProfile('user-123');

      verify(mockService.getUserProfile('user-123')).called(2);
    });

    test('should return DataGenericFailed when the service throws', () async {
      when(mockService.getUserProfile('user-123'))
          .thenThrow(Exception('Firestore read failed'));

      final result = await repository.getAuthorProfile('user-123');

      expect(result, isA<DataGenericFailed<UserProfileEntity?>>());
    });
  });

  group('uploadAvatar', () {
    test('should return the download URL', () async {
      final avatar = File('path/to/avatar.png');
      when(mockService.uploadAvatar('user-123', avatar))
          .thenAnswer((_) async => 'https://example.com/new.jpg');

      final result =
          await repository.uploadAvatar('user-123', avatar);

      expect(result, isA<DataSuccess<String?>>());
      expect(result.data, 'https://example.com/new.jpg');
    });

    test('should return DataGenericFailed when the upload throws', () async {
      final avatar = File('path/to/avatar.png');
      when(mockService.uploadAvatar('user-123', avatar))
          .thenThrow(Exception('Storage upload failed'));

      final result =
          await repository.uploadAvatar('user-123', avatar);

      expect(result, isA<DataGenericFailed<String?>>());
      expect(result.errorMessage, contains('Storage upload failed'));
    });
  });

  group('updateUserProfile', () {
    test('should save and return the updated profile', () async {
      when(mockService.getUserProfile('user-123')).thenAnswer(
          (_) async => const UserProfileModel(id: 'user-123'));
      when(mockService.saveUserProfile(any)).thenAnswer((_) async {});

      final result = await repository.updateUserProfile(
        userId: 'user-123',
        displayName: 'Jane',
        photoUrl: 'https://example.com/new.jpg',
      );

      expect(result, isA<DataSuccess<UserProfileEntity>>());
      expect(result.data!.displayName, 'Jane');
      expect(result.data!.photoUrl, 'https://example.com/new.jpg');
      final saved = verify(mockService.saveUserProfile(captureAny))
          .captured
          .single as UserProfileModel;
      expect(saved.id, 'user-123');
      expect(saved.photoUrl, 'https://example.com/new.jpg');
    });

    test('should keep the existing photo when no new URL is given', () async {
      when(mockService.getUserProfile('user-123'))
          .thenAnswer((_) async => tProfile);
      when(mockService.saveUserProfile(any)).thenAnswer((_) async {});

      final result = await repository.updateUserProfile(
        userId: 'user-123',
        displayName: 'Jane',
      );

      expect(result.data!.photoUrl, 'https://example.com/avatar.jpg');
    });

    test('should return DataGenericFailed when the save throws', () async {
      when(mockService.getUserProfile('user-123'))
          .thenAnswer((_) async => tProfile);
      when(mockService.saveUserProfile(any))
          .thenThrow(Exception('Firestore write failed'));

      final result = await repository.updateUserProfile(
        userId: 'user-123',
        displayName: 'Jane',
        photoUrl: 'https://example.com/new.jpg',
      );

      expect(result, isA<DataGenericFailed<UserProfileEntity>>());
      expect(result.errorMessage, contains('Firestore write failed'));
    });
  });
}
