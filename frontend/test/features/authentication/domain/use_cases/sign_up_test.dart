import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/entities/auth_failures.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/sign_up.dart';

import '../../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late SignUpUseCase signUp;

  setUp(() {
    repository = FakeAuthRepository();
    signUp = SignUpUseCase(repository);
  });

  test('registers an account with valid credentials', () async {
    final result = await signUp(const SignUpParams(
      email: 'alex@example.com',
      password: 'a-good-password',
      confirmPassword: 'a-good-password',
      displayName: 'Alex Rivera',
    ));

    expect(result, isA<DataSuccess>());
    expect(repository.signUpCallCount, 1);
    expect(repository.lastDisplayName, 'Alex Rivera');
  });

  test('trims the email before it reaches the backend', () async {
    await signUp(const SignUpParams(
      email: '  alex@example.com ',
      password: 'a-good-password',
      confirmPassword: 'a-good-password',
    ));

    expect(repository.lastEmail, 'alex@example.com');
  });

  test('rejects a malformed email and never reaches the backend', () async {
    final result = await signUp(const SignUpParams(
      email: 'not-an-email',
      password: 'a-good-password',
      confirmPassword: 'a-good-password',
    ));

    expect(result, isA<DataFailed>());
    expect(
      (result.error as CredentialsValidationException).errors,
      contains(CredentialsValidationError.emailMalformed),
    );
    expect(repository.signUpCallCount, 0);
  });

  test('rejects a password shorter than the minimum', () async {
    final result = await signUp(const SignUpParams(
      email: 'alex@example.com',
      password: 'short',
      confirmPassword: 'short',
    ));

    expect(
      (result.error as CredentialsValidationException).errors,
      contains(CredentialsValidationError.passwordTooShort),
    );
    expect(repository.signUpCallCount, 0);
  });

  test('rejects two passwords that do not match', () async {
    final result = await signUp(const SignUpParams(
      email: 'alex@example.com',
      password: 'a-good-password',
      confirmPassword: 'a-different-password',
    ));

    expect(
      (result.error as CredentialsValidationException).errors,
      contains(CredentialsValidationError.passwordsDoNotMatch),
    );
    expect(repository.signUpCallCount, 0);
  });

  test('propagates an address that is already registered', () async {
    repository.signUpResult =
        const DataFailed(EmailAlreadyRegisteredException());

    final result = await signUp(const SignUpParams(
      email: 'alex@example.com',
      password: 'a-good-password',
      confirmPassword: 'a-good-password',
    ));

    expect(result.error, isA<EmailAlreadyRegisteredException>());
  });
}
