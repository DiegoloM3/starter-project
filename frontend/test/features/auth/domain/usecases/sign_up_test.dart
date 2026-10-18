import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/auth_validation.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';

import 'auth_test_data.dart';

void main() {
  late MockAuthRepository repository;

  setUpAll(() => registerFallbackValue(SignUpParams(firstName: '', lastName: '', email: '', password: '')));

  setUp(() => repository = MockAuthRepository());

  test('signs up through the repository', () async {
    final params = SignUpParams(firstName: 'Jane', lastName: 'Doe', email: 'jane@test.com', password: 'password123');
    when(() => repository.signUp(params)).thenAnswer((_) async => const DataSuccess(testUser));

    final result = await SignUpUseCase(repository).call(params);

    expect(result.data, testUser);
  });

  test('fails with the validation errors without calling the repository', () async {
    final params = SignUpParams(firstName: '', lastName: 'Doe', email: 'jane@test.com', password: 'password123');

    final result = await SignUpUseCase(repository).call(params);

    final error = result.error as AuthValidationException;
    expect(error.errors, {AuthValidationError.firstNameEmpty});
    verifyNever(() => repository.signUp(any()));
  });
}
