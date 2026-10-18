import 'dart:typed_data';

/// Limits shared with the Firestore and Storage security rules.
class ProfileLimits {
  static const int nameMaxLength = 40;
  static const int bioMaxLength = 300;
  static const int photoMaxBytes = 5 * 1024 * 1024;
}

enum ProfileValidationError {
  firstNameEmpty,
  firstNameTooLong,
  lastNameEmpty,
  lastNameTooLong,
  bioTooLong,
  photoTooLarge,
}

class UpdateProfileParams {
  final String firstName;
  final String lastName;
  final String bio;

  /// Null keeps the current photo.
  final Uint8List? newPhoto;

  UpdateProfileParams({required String firstName, required String lastName, required String bio, this.newPhoto})
    : firstName = firstName.trim(),
      lastName = lastName.trim(),
      bio = bio.trim();

  Set<ProfileValidationError> get validationErrors => {
    if (firstName.isEmpty) ProfileValidationError.firstNameEmpty,
    if (firstName.length > ProfileLimits.nameMaxLength) ProfileValidationError.firstNameTooLong,
    if (lastName.isEmpty) ProfileValidationError.lastNameEmpty,
    if (lastName.length > ProfileLimits.nameMaxLength) ProfileValidationError.lastNameTooLong,
    if (bio.length > ProfileLimits.bioMaxLength) ProfileValidationError.bioTooLong,
    if ((newPhoto?.length ?? 0) >= ProfileLimits.photoMaxBytes) ProfileValidationError.photoTooLarge,
  };
}
