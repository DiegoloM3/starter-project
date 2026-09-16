import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_email.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository auth;
  late SignInWithEmailUseCase useCase;

  setUp(() {
    auth = MockAuthRepository();
    useCase = SignInWithEmailUseCase(auth);
  });

  test('rejects invalid input locally without calling the provider', () async {
    const params = SignInParams(email: 'nope', password: 'x');

    final result = await useCase(params);

    expect(result.failureOrNull?.type, FailureType.validation);
    expect(result.failureOrNull?.message, CredentialValidationError.invalidEmail.message);
    verifyZeroInteractions(auth);
  });

  test('delegates valid input to the repository', () async {
    const params = SignInParams(email: 'ada@example.com', password: 'secret');
    when(() => auth.signInWithEmail(params)).thenAnswer((_) async => const DataSuccess(user));

    final result = await useCase(params);

    expect(result.dataOrNull, user);
  });

  test('passes provider failures through', () async {
    const params = SignInParams(email: 'ada@example.com', password: 'wrong');
    when(() => auth.signInWithEmail(params))
        .thenAnswer((_) async => const DataFailed(Failure.invalidCredentials()));

    final result = await useCase(params);

    expect(result.failureOrNull?.type, FailureType.invalidCredentials);
  });
}
