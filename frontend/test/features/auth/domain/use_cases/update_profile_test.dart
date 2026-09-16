import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/profile_update.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/profile_photo_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/update_profile.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

class MockProfilePhotoRepository extends Mock implements ProfilePhotoRepository {}

void main() {
  setUpAll(() => registerFallbackValue(buildImage()));

  late MockAuthRepository auth;
  late MockProfilePhotoRepository photos;
  late UpdateProfileUseCase useCase;

  setUp(() {
    auth = MockAuthRepository();
    photos = MockProfilePhotoRepository();
    useCase = UpdateProfileUseCase(auth, photos);
    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.updateProfile(
          displayName: any(named: 'displayName'),
          photoUrl: any(named: 'photoUrl'),
        )).thenAnswer((invocation) async => DataSuccess(user.copyWith(
          displayName: invocation.namedArguments[#displayName] as String?,
          photoUrl: invocation.namedArguments[#photoUrl] as String?,
        )));
  });

  test('a name change is trimmed and sent without touching storage', () async {
    final result = await useCase(const ProfileUpdate(displayName: '  Grace  '));

    expect(result.dataOrNull?.displayName, 'Grace');
    verify(() => auth.updateProfile(displayName: 'Grace', photoUrl: null)).called(1);
    verifyNever(() => photos.upload(userId: any(named: 'userId'), image: any(named: 'image')));
  });

  test('a photo is uploaded first and its URL stored on the profile', () async {
    when(() => photos.upload(userId: 'uid-1', image: buildImage()))
        .thenAnswer((_) async => const DataSuccess('https://cdn/avatar.jpg'));

    final result = await useCase(ProfileUpdate(photo: buildImage()));

    expect(result.dataOrNull?.photoUrl, 'https://cdn/avatar.jpg');
    verify(() => auth.updateProfile(displayName: null, photoUrl: 'https://cdn/avatar.jpg')).called(1);
  });

  test('a failed upload stops before the profile is touched', () async {
    when(() => photos.upload(userId: any(named: 'userId'), image: any(named: 'image')))
        .thenAnswer((_) async => const DataFailed(Failure.network()));

    final result = await useCase(ProfileUpdate(photo: buildImage()));

    expect(result.failureOrNull, const Failure.network());
    verifyNever(() => auth.updateProfile(displayName: any(named: 'displayName'), photoUrl: any(named: 'photoUrl')));
  });

  test('validation rejects a blank or too-short name and an oversized photo', () async {
    expect((await useCase(const ProfileUpdate(displayName: ' '))).failureOrNull?.type, FailureType.validation);
    expect((await useCase(const ProfileUpdate(displayName: 'A'))).failureOrNull?.type, FailureType.validation);
    expect(
      (await useCase(ProfileUpdate(photo: buildImage(sizeInBytes: 6 * 1024 * 1024)))).failureOrNull?.type,
      FailureType.validation,
    );
  });

  test('nothing to change returns the current user; signed out is refused', () async {
    expect((await useCase(const ProfileUpdate())).dataOrNull, user);

    when(() => auth.currentUser).thenReturn(null);
    expect((await useCase(const ProfileUpdate(displayName: 'Grace'))).failureOrNull?.type, FailureType.unauthenticated);
  });
}
