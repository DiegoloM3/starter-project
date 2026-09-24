import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/entities/auth_failures.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/params/request_password_reset_params.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/request_password_reset.dart';

import '../../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late RequestPasswordResetUseCase requestPasswordReset;

  setUp(() {
    repository = FakeAuthRepository();
    requestPasswordReset = RequestPasswordResetUseCase(repository);
  });

  test('asks the backend to start a reset', () async {
    final result = await requestPasswordReset(
      const RequestPasswordResetParams('  alex@example.com '),
    );

    expect(result, isA<DataSuccess>());
    expect(repository.passwordResetCallCount, 1);
    expect(repository.lastEmail, 'alex@example.com');
  });

  test('rejects a malformed address without asking the backend', () async {
    final result = await requestPasswordReset(
      const RequestPasswordResetParams('not-an-email'),
    );

    expect(
      (result.error as CredentialsValidationException).errors,
      contains(CredentialsValidationError.emailMalformed),
    );
    expect(repository.passwordResetCallCount, 0);
  });
}
