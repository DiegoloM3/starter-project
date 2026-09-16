import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up_with_email.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository auth;
  late SignUpWithEmailUseCase useCase;

  const valid = SignUpParams(
    displayName: 'Ada',
    email: 'ada@example.com',
    password: 'longenough',
  );

  setUp(() {
    auth = MockAuthRepository();
    useCase = SignUpWithEmailUseCase(auth);
  });

  test('rejects a weak form locally, reporting the first problem', () async {
    const params = SignUpParams(displayName: '', email: 'ada@example.com', password: 'short');

    final result = await useCase(params);

    expect(result.failureOrNull?.type, FailureType.validation);
    expect(result.failureOrNull?.message, CredentialValidationError.emptyDisplayName.message);
    verifyZeroInteractions(auth);
  });

  test('delegates a valid form to the repository', () async {
    when(() => auth.signUpWithEmail(valid)).thenAnswer((_) async => const DataSuccess(user));

    final result = await useCase(valid);

    expect(result.dataOrNull, user);
  });

  test('passes an email-already-in-use failure through', () async {
    when(() => auth.signUpWithEmail(valid))
        .thenAnswer((_) async => const DataFailed(Failure.emailAlreadyInUse()));

    final result = await useCase(valid);

    expect(result.failureOrNull?.type, FailureType.emailAlreadyInUse);
  });
}
