import 'auth_validation.dart';

class SignInParams {
  final String email;
  final String password;

  SignInParams({required String email, required this.password}) : email = email.trim();

  Set<AuthValidationError> get validationErrors => {
    if (!isValidEmail(email)) AuthValidationError.emailInvalid,
    if (password.isEmpty) AuthValidationError.passwordEmpty,
  };
}
