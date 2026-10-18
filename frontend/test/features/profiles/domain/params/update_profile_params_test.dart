import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/params/update_profile_params.dart';

void main() {
  UpdateProfileParams buildParams({
    String firstName = 'Jane',
    String lastName = 'Doe',
    String bio = 'Journalist',
    Uint8List? newPhoto,
  }) {
    return UpdateProfileParams(firstName: firstName, lastName: lastName, bio: bio, newPhoto: newPhoto);
  }

  test('removes surrounding spaces', () {
    final params = buildParams(firstName: ' Jane ', lastName: ' Doe ', bio: ' Hi ');

    expect([params.firstName, params.lastName, params.bio], ['Jane', 'Doe', 'Hi']);
  });

  test('is valid with an empty bio and without a new photo', () {
    expect(buildParams(bio: '').validationErrors, isEmpty);
  });

  test('reports empty names', () {
    expect(buildParams(firstName: ' ', lastName: '').validationErrors, {
      ProfileValidationError.firstNameEmpty,
      ProfileValidationError.lastNameEmpty,
    });
  });

  test('reports names and bio longer than the limits', () {
    final params = buildParams(
      firstName: 'a' * (ProfileLimits.nameMaxLength + 1),
      lastName: 'a' * (ProfileLimits.nameMaxLength + 1),
      bio: 'a' * (ProfileLimits.bioMaxLength + 1),
    );

    expect(params.validationErrors, {
      ProfileValidationError.firstNameTooLong,
      ProfileValidationError.lastNameTooLong,
      ProfileValidationError.bioTooLong,
    });
  });

  test('reports a photo of the size limit or more', () {
    final params = buildParams(newPhoto: Uint8List(ProfileLimits.photoMaxBytes));

    expect(params.validationErrors, {ProfileValidationError.photoTooLarge});
  });
}
