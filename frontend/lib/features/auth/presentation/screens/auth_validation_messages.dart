import '../../domain/params/auth_validation.dart';

extension AuthValidationMessage on AuthValidationError {
  String get message => switch (this) {
    AuthValidationError.firstNameEmpty => 'Escribe tu nombre.',
    AuthValidationError.firstNameTooLong => 'Máximo ${AuthLimits.nameMaxLength} caracteres.',
    AuthValidationError.lastNameEmpty => 'Escribe tu apellido.',
    AuthValidationError.lastNameTooLong => 'Máximo ${AuthLimits.nameMaxLength} caracteres.',
    AuthValidationError.emailInvalid => 'Escribe un email válido.',
    AuthValidationError.passwordEmpty => 'Escribe tu contraseña.',
    AuthValidationError.passwordTooShort => 'Mínimo ${AuthLimits.passwordMinLength} caracteres.',
  };
}

/// The message of the first error that belongs to a field, or null when the field is valid.
String? messageForField(Set<AuthValidationError> errors, Set<AuthValidationError> fieldErrors) {
  for (final error in errors) {
    if (fieldErrors.contains(error)) return error.message;
  }
  return null;
}

const firstNameErrors = {AuthValidationError.firstNameEmpty, AuthValidationError.firstNameTooLong};
const lastNameErrors = {AuthValidationError.lastNameEmpty, AuthValidationError.lastNameTooLong};
const emailErrors = {AuthValidationError.emailInvalid};
const passwordErrors = {AuthValidationError.passwordEmpty, AuthValidationError.passwordTooShort};

const String unexpectedErrorMessage = 'Algo salió mal. Revisa tu conexión e inténtalo de nuevo.';
