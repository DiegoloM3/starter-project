import 'auth_validation.dart';

class SignUpParams {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  SignUpParams({
    required String firstName,
    required String lastName,
    required String email,
    required this.password,
  })  : firstName = firstName.trim(),
        lastName = lastName.trim(),
        email = email.trim();

  Set<AuthValidationError> get validationErrors => {
        ..._firstNameErrors(),
        ..._lastNameErrors(),
        if (!isValidEmail(email)) AuthValidationError.emailInvalid,
        if (password.length < AuthLimits.passwordMinLength) AuthValidationError.passwordTooShort,
      };

  Iterable<AuthValidationError> _firstNameErrors() sync* {
    if (firstName.isEmpty) yield AuthValidationError.firstNameEmpty;
    if (firstName.length > AuthLimits.nameMaxLength) yield AuthValidationError.firstNameTooLong;
  }

  Iterable<AuthValidationError> _lastNameErrors() sync* {
    if (lastName.isEmpty) yield AuthValidationError.lastNameEmpty;
    if (lastName.length > AuthLimits.nameMaxLength) yield AuthValidationError.lastNameTooLong;
  }
}
