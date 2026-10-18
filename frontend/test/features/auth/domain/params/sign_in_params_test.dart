import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/auth_validation.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';

void main() {
  group('SignInParams.validationErrors', () {
    test('is empty for valid params', () {
      final params = SignInParams(email: 'jane@test.com', password: 'any');

      expect(params.validationErrors, isEmpty);
    });

    test('reports an invalid email', () {
      final params = SignInParams(email: 'jane', password: 'any');

      expect(params.validationErrors, {AuthValidationError.emailInvalid});
    });

    test('reports an empty password', () {
      final params = SignInParams(email: 'jane@test.com', password: '');

      expect(params.validationErrors, {AuthValidationError.passwordEmpty});
    });
  });
}
