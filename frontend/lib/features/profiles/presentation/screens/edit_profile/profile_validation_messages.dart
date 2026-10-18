import '../../../domain/params/update_profile_params.dart';

extension ProfileValidationMessage on ProfileValidationError {
  String get message => switch (this) {
    ProfileValidationError.firstNameEmpty => 'Escribe tu nombre.',
    ProfileValidationError.firstNameTooLong => 'Máximo ${ProfileLimits.nameMaxLength} caracteres.',
    ProfileValidationError.lastNameEmpty => 'Escribe tu apellido.',
    ProfileValidationError.lastNameTooLong => 'Máximo ${ProfileLimits.nameMaxLength} caracteres.',
    ProfileValidationError.bioTooLong => 'Máximo ${ProfileLimits.bioMaxLength} caracteres.',
    ProfileValidationError.photoTooLarge =>
      'La foto debe pesar menos de ${ProfileLimits.photoMaxBytes ~/ (1024 * 1024)} MB.',
  };
}

/// The message of the first error that belongs to a field, or null when the field is valid.
String? messageForField(Set<ProfileValidationError> errors, Set<ProfileValidationError> fieldErrors) {
  for (final error in errors) {
    if (fieldErrors.contains(error)) return error.message;
  }
  return null;
}

const firstNameErrors = {ProfileValidationError.firstNameEmpty, ProfileValidationError.firstNameTooLong};
const lastNameErrors = {ProfileValidationError.lastNameEmpty, ProfileValidationError.lastNameTooLong};
const bioErrors = {ProfileValidationError.bioTooLong};
const photoErrors = {ProfileValidationError.photoTooLarge};
