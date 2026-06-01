import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/auth/domain/use_cases/delete_account_use_case.dart';
import 'package:tortutip/features/profile/domain/use_cases/upload_avatar_use_case.dart';
import 'package:tortutip/features/profile/presentation/bloc/edit_profile_cubit.dart';
import 'package:tortutip/features/profile/presentation/bloc/edit_profile_state.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/user/domain/use_cases/update_user_profile_use_case.dart';
import 'package:tortutip/core/usecase/usecase.dart';

class MockUpdateUserProfileUseCase extends Mock
    implements UpdateUserProfileUseCase {}

class MockUploadAvatarUseCase extends Mock implements UploadAvatarUseCase {}

class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

class FakeFile extends Fake implements File {}

class FakeUploadAvatarParams extends Fake implements UploadAvatarParams {}

class FakeUpdateUserProfileParams extends Fake
    implements UpdateUserProfileParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late MockUpdateUserProfileUseCase mockUpdateProfile;
  late MockUploadAvatarUseCase mockUploadAvatar;
  late MockDeleteAccountUseCase mockDeleteAccount;

  final testUser = UserEntity(
    id: 'user_1',
    name: 'Test User',
    email: 'test@test.com',
    avatarUrl: '',
    bio: '',
    role: 'reader',
    gender: '',
    ageRange: '',
    createdAt: DateTime(2024),
  );

  setUpAll(() {
    registerFallbackValue(FakeUploadAvatarParams());
    registerFallbackValue(FakeUpdateUserProfileParams());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockUpdateProfile = MockUpdateUserProfileUseCase();
    mockUploadAvatar = MockUploadAvatarUseCase();
    mockDeleteAccount = MockDeleteAccountUseCase();
  });

  EditProfileCubit buildCubit() =>
      EditProfileCubit(mockUpdateProfile, mockUploadAvatar, mockDeleteAccount);

  group('EditProfileCubit', () {
    blocTest<EditProfileCubit, EditProfileState>(
      'should_emit_ImageUploading_then_ImageUploaded_when_uploadAvatar_succeeds',
      build: () {
        when(() => mockUploadAvatar(any()))
            .thenAnswer((_) async => const DataSuccess('https://avatar.url'));
        return buildCubit();
      },
      act: (c) => c.uploadAvatar(FakeFile(), 'user_1'),
      expect: () => [
        isA<EditProfileImageUploading>(),
        isA<EditProfileImageUploaded>(),
      ],
      verify: (c) {
        final uploaded = c.state as EditProfileImageUploaded;
        expect(uploaded.avatarUrl, 'https://avatar.url');
      },
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'should_emit_ImageUploading_then_Error_when_uploadAvatar_fails',
      build: () {
        when(() => mockUploadAvatar(any()))
            .thenAnswer((_) async => DataFailed(Exception('upload error')));
        return buildCubit();
      },
      act: (c) => c.uploadAvatar(FakeFile(), 'user_1'),
      expect: () => [
        isA<EditProfileImageUploading>(),
        isA<EditProfileError>(),
      ],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'should_emit_Loading_then_Success_when_saveProfile_succeeds',
      build: () {
        when(() => mockUpdateProfile(any()))
            .thenAnswer((_) async => DataSuccess(testUser));
        return buildCubit();
      },
      act: (c) => c.saveProfile(
        currentUser: testUser,
        name: 'New Name',
        bio: 'New bio',
      ),
      expect: () => [
        isA<EditProfileLoading>(),
        isA<EditProfileSuccess>(),
      ],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'should_emit_Loading_then_Error_when_saveProfile_fails',
      build: () {
        when(() => mockUpdateProfile(any()))
            .thenAnswer((_) async => DataFailed(Exception('save error')));
        return buildCubit();
      },
      act: (c) => c.saveProfile(
        currentUser: testUser,
        name: 'New Name',
        bio: 'New bio',
      ),
      expect: () => [
        isA<EditProfileLoading>(),
        isA<EditProfileError>(),
      ],
    );
  });
}
