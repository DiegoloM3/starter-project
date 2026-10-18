import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/auth_validation.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/delete_account.dart';

import 'auth_test_data.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  test('deletes the account confirming the password', () async {
    when(() => repository.deleteAccount('password')).thenAnswer((_) async => const DataSuccess(null));

    final result = await DeleteAccountUseCase(repository).call('password');

    expect(result, isA<DataSuccess>());
  });

  test('requires the password without calling the repository', () async {
    final result = await DeleteAccountUseCase(repository).call('');

    final error = result.error as AuthValidationException;
    expect(error.errors, {AuthValidationError.passwordEmpty});
    verifyNever(() => repository.deleteAccount(any()));
  });
}
