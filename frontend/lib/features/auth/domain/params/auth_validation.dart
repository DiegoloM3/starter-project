/// Limits shared with the Firestore security rules and Firebase Authentication.
class AuthLimits {
  static const int nameMaxLength = 40;
  static const int passwordMinLength = 8;
}

enum AuthValidationError {
  firstNameEmpty,
  firstNameTooLong,
  lastNameEmpty,
  lastNameTooLong,
  emailInvalid,
  passwordEmpty,
  passwordTooShort,
}

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String email) => _emailPattern.hasMatch(email);
