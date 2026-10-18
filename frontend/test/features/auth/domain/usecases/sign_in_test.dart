import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/auth_validation.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/mock/mock_users.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';

void main() {
  final signIn = SignInUseCase();

  test('signs in the mock journalist', () async {
    final params = SignInParams(email: mockJournalistEmail, password: 'any');

    final result = await signIn(params);

    expect(result, isA<DataSuccess>());
    expect(result.data!.role, UserRole.journalist);
  });

  test('signs in any other email as a reader', () async {
    final params = SignInParams(email: 'reader@test.com', password: 'any');

    final result = await signIn(params);

    expect(result.data!.role, UserRole.reader);
  });

  test('fails with the validation errors of invalid params', () async {
    final params = SignInParams(email: 'jane', password: '');

    final result = await signIn(params);

    final error = result.error as AuthValidationException;
    expect(error.errors, {AuthValidationError.emailInvalid, AuthValidationError.passwordEmpty});
  });
}
