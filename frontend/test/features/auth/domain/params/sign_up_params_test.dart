import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/auth_validation.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';

SignUpParams buildParams({
  String firstName = 'Jane',
  String lastName = 'Doe',
  String email = 'jane@test.com',
  String password = 'password123',
}) {
  return SignUpParams(firstName: firstName, lastName: lastName, email: email, password: password);
}

void main() {
  group('SignUpParams.validationErrors', () {
    test('is empty for valid params', () {
      expect(buildParams().validationErrors, isEmpty);
    });

    test('reports an empty first name, ignoring spaces', () {
      expect(buildParams(firstName: '  ').validationErrors, {AuthValidationError.firstNameEmpty});
    });

    test('reports a first name longer than the maximum length', () {
      final firstName = 'a' * (AuthLimits.nameMaxLength + 1);

      expect(buildParams(firstName: firstName).validationErrors, {AuthValidationError.firstNameTooLong});
    });

    test('reports an empty last name', () {
      expect(buildParams(lastName: '').validationErrors, {AuthValidationError.lastNameEmpty});
    });

    test('reports a last name longer than the maximum length', () {
      final lastName = 'a' * (AuthLimits.nameMaxLength + 1);

      expect(buildParams(lastName: lastName).validationErrors, {AuthValidationError.lastNameTooLong});
    });

    for (final invalidEmail in ['', 'jane', 'jane@test', 'jane @test.com']) {
      test('reports the invalid email "$invalidEmail"', () {
        expect(buildParams(email: invalidEmail).validationErrors, {AuthValidationError.emailInvalid});
      });
    }

    test('reports a password shorter than the minimum length', () {
      final password = 'a' * (AuthLimits.passwordMinLength - 1);

      expect(buildParams(password: password).validationErrors, {AuthValidationError.passwordTooShort});
    });
  });
}
