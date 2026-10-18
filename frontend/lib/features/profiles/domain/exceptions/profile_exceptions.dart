import '../params/update_profile_params.dart';

class ProfileValidationException implements Exception {
  final Set<ProfileValidationError> errors;

  const ProfileValidationException(this.errors);
}
