import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/auth_validation.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';

void main() {
  final signUp = SignUpUseCase();

  test('registers new users as readers', () async {
    final params = SignUpParams(firstName: 'Jane', lastName: 'Doe', email: 'jane@test.com', password: 'password123');

    final result = await signUp(params);

    expect(result, isA<DataSuccess>());
    expect(result.data!.fullName, 'Jane Doe');
    expect(result.data!.role, UserRole.reader);
  });

  test('removes surrounding spaces from the names', () async {
    final params = SignUpParams(firstName: ' Jane ', lastName: ' Doe ', email: 'jane@test.com', password: 'password123');

    final result = await signUp(params);

    expect(result.data!.fullName, 'Jane Doe');
  });

  test('fails with the validation errors of invalid params', () async {
    final params = SignUpParams(firstName: '', lastName: 'Doe', email: 'jane@test.com', password: 'password123');

    final result = await signUp(params);

    final error = result.error as AuthValidationException;
    expect(error.errors, {AuthValidationError.firstNameEmpty});
  });
}
