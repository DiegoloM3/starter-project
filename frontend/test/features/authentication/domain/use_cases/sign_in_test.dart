import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/entities/auth_failures.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/sign_in.dart';

import '../../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late SignInUseCase signIn;

  setUp(() {
    repository = FakeAuthRepository();
    signIn = SignInUseCase(repository);
  });

  test('signs in with credentials that look usable', () async {
    final result = await signIn(const SignInParams(
      email: 'alex@example.com',
      password: 'a-good-password',
    ));

    expect(result, isA<DataSuccess>());
    expect(repository.signInCallCount, 1);
  });

  test('accepts a short password, because the account may predate the rule',
      () async {
    await signIn(const SignInParams(
      email: 'alex@example.com',
      password: 'old',
    ));

    expect(repository.signInCallCount, 1);
  });

  test('still rejects an empty password without asking the backend', () async {
    final result = await signIn(const SignInParams(
      email: 'alex@example.com',
      password: '',
    ));

    expect(
      (result.error as CredentialsValidationException).errors,
      contains(CredentialsValidationError.passwordRequired),
    );
    expect(repository.signInCallCount, 0);
  });

  test('reports wrong credentials without saying which half was wrong',
      () async {
    repository.signInResult = const DataFailed(InvalidCredentialsException());

    final result = await signIn(const SignInParams(
      email: 'alex@example.com',
      password: 'a-good-password',
    ));

    expect(result.error, isA<InvalidCredentialsException>());
  });
}
