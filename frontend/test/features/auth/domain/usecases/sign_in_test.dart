import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/auth_validation.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';

import 'auth_test_data.dart';

void main() {
  late MockAuthRepository repository;

  setUpAll(() => registerFallbackValue(SignInParams(email: '', password: '')));

  setUp(() => repository = MockAuthRepository());

  test('signs in through the repository', () async {
    final params = SignInParams(email: 'jane@test.com', password: 'password');
    when(() => repository.signIn(params)).thenAnswer((_) async => const DataSuccess(testUser));

    final result = await SignInUseCase(repository).call(params);

    expect(result.data, testUser);
  });

  test('fails with the validation errors without calling the repository', () async {
    final result = await SignInUseCase(repository).call(SignInParams(email: 'jane', password: ''));

    final error = result.error as AuthValidationException;
    expect(error.errors, {AuthValidationError.emailInvalid, AuthValidationError.passwordEmpty});
    verifyNever(() => repository.signIn(any()));
  });
}
