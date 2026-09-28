import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/update_user_profile.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/profile/profile_bloc.dart';

import 'profile_bloc_test.mocks.dart';

@GenerateMocks([GetCurrentUserUseCase, UpdateUserProfile])
void main() {
  late MockGetCurrentUserUseCase mockGetCurrentUser;
  late MockUpdateUserProfile mockUpdateUserProfile;

  const tUser = UserEntity(
    id: 'user-123',
    email: 'jane@example.com',
    displayName: 'Jane Doe',
    photoUrl: 'https://example.com/avatar.jpg',
  );

  const tProfile = UserProfileEntity(
    id: 'user-123',
    displayName: 'Jane',
    photoUrl: 'https://example.com/new.jpg',
  );

  setUp(() {
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    mockUpdateUserProfile = MockUpdateUserProfile();
  });

  ProfileBloc buildBloc() =>
      ProfileBloc(mockGetCurrentUser, mockUpdateUserProfile);

  test('initial state is ProfileLoading', () {
    expect(buildBloc().state, isA<ProfileLoading>());
  });

  blocTest<ProfileBloc, ProfileState>(
    'emits [Loading, Done] with the current values on LoadProfile',
    build: () {
      when(mockGetCurrentUser.call())
          .thenAnswer((_) async => const DataSuccess(tUser));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadProfile()),
    expect: () => [
      const ProfileLoading(),
      const ProfileDone(
        userId: 'user-123',
        email: 'jane@example.com',
        displayName: 'Jane Doe',
        photoUrl: 'https://example.com/avatar.jpg',
      ),
    ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'emits [Loading, Error] when nobody is logged in',
    build: () {
      when(mockGetCurrentUser.call())
          .thenAnswer((_) async => const DataSuccess(null));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadProfile()),
    expect: () => [
      const ProfileLoading(),
      const ProfileError('Please log in to edit your profile.'),
    ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'emits [Saving, Saved] when the update succeeds',
    build: () {
      when(mockUpdateUserProfile.call(params: anyNamed('params')))
          .thenAnswer((_) async => const DataSuccess(tProfile));
      return buildBloc();
    },
    act: (bloc) => bloc.add(SaveProfile(
      userId: 'user-123',
      displayName: '  Jane  ',
      avatarFile: File('path/to/avatar.png'),
    )),
    expect: () => [
      const ProfileSaving(),
      const ProfileSaved(),
    ],
    verify: (_) {
      final params = verify(mockUpdateUserProfile.call(
        params: captureAnyNamed('params'),
      )).captured.single as UpdateUserProfileParams;
      expect(params.userId, 'user-123');
      expect(params.displayName, 'Jane');
      expect(params.avatarFile?.path, 'path/to/avatar.png');
    },
  );

  blocTest<ProfileBloc, ProfileState>(
    'emits [Error] when the name is empty without calling the use case',
    build: () => buildBloc(),
    act: (bloc) => bloc.add(const SaveProfile(
      userId: 'user-123',
      displayName: '   ',
    )),
    expect: () => [
      const ProfileError('Name cannot be empty.'),
    ],
    verify: (_) {
      verifyZeroInteractions(mockUpdateUserProfile);
    },
  );

  blocTest<ProfileBloc, ProfileState>(
    'emits [Saving, Error] when the update fails',
    build: () {
      when(mockUpdateUserProfile.call(params: anyNamed('params'))).thenAnswer(
          (_) async => const DataGenericFailed('Failed to save profile'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const SaveProfile(
      userId: 'user-123',
      displayName: 'Jane',
    )),
    expect: () => [
      const ProfileSaving(),
      const ProfileError('Failed to save profile'),
    ],
  );
}
