import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/profile_update.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/edit_profile/edit_profile_cubit.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const ProfileUpdate());
  });

  late MockUpdateProfileUseCase updateProfile;
  late MockPickImageUseCase pickPhoto;
  late EditProfileCubit cubit;

  setUp(() {
    updateProfile = MockUpdateProfileUseCase();
    pickPhoto = MockPickImageUseCase();
    when(() => updateProfile(any())).thenAnswer((_) async => DataSuccess(user));
    when(() => pickPhoto(any())).thenAnswer((_) async => DataSuccess(buildImage()));
    cubit = EditProfileCubit(updateProfile, pickPhoto, user: user);
  });
  tearDown(() => cubit.close());

  test('starts from the stored name with nothing to save', () {
    expect(cubit.state.displayName, 'Ada Lovelace');
    expect(cubit.state.hasChanges, isFalse);
    expect(cubit.state.update.isEmpty, isTrue);
  });

  test('only the fields that changed are sent', () async {
    cubit.displayNameChanged('Grace Hopper');
    await cubit.submit();
    verify(() => updateProfile(const ProfileUpdate(displayName: 'Grace Hopper'))).called(1);
    expect(cubit.state.status, EditProfileStatus.success);

    cubit.displayNameChanged('Ada Lovelace');
    await cubit.pickPhoto();
    await cubit.submit();
    verify(() => updateProfile(ProfileUpdate(photo: buildImage()))).called(1);
  });

  test('a too-short name is reported under the field, never sent', () async {
    cubit.displayNameChanged('A');
    await cubit.submit();

    expect(cubit.state.displayNameError, CredentialValidationError.shortDisplayName);
    verifyNever(() => updateProfile(any()));
  });

  test('a rejected save keeps the form with the failure', () async {
    when(() => updateProfile(any())).thenAnswer((_) async => const DataFailed(Failure.network()));
    cubit.displayNameChanged('Grace');

    await cubit.submit();

    expect(cubit.state.status, EditProfileStatus.failure);
    expect(cubit.state.failure, const Failure.network());
  });

  test('a photo pick that fails keeps the form and reports it', () async {
    when(() => pickPhoto(any())).thenAnswer((_) async => const DataFailed(Failure.cancelled()));

    await cubit.pickPhoto();

    expect(cubit.state.photo, isNull);
    expect(cubit.state.failure, const Failure.cancelled());
  });
}
