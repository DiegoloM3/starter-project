import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_up/sign_up_cubit.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const SignUpParams(displayName: '', email: '', password: ''));
  });

  late MockSignUpWithEmailUseCase signUpWithEmail;
  late MockSignInWithGoogleUseCase signInWithGoogle;
  late SignUpCubit cubit;

  setUp(() {
    signUpWithEmail = MockSignUpWithEmailUseCase();
    signInWithGoogle = MockSignInWithGoogleUseCase();
    cubit = SignUpCubit(signUpWithEmail, signInWithGoogle);
  });
  tearDown(() => cubit.close());

  void fillValidForm() {
    cubit
      ..displayNameChanged('Ada Lovelace')
      ..emailChanged('ada@example.com')
      ..passwordChanged('Harbour-lamp-42');
  }

  test('submit on an empty form reports one error per field', () async {
    await cubit.submit();

    expect(cubit.state.status, SignUpStatus.failure);
    expect(cubit.state.displayNameError, CredentialValidationError.emptyDisplayName);
    expect(cubit.state.emailError, CredentialValidationError.emptyEmail);
    expect(cubit.state.passwordError, CredentialValidationError.emptyPassword);
    verifyNever(() => signUpWithEmail(any()));
  });

  test('typing in one field clears only that field\'s error', () async {
    await cubit.submit();

    cubit.passwordChanged('secret123');

    expect(cubit.state.passwordError, isNull);
    expect(cubit.state.displayNameError, CredentialValidationError.emptyDisplayName);
    expect(cubit.state.emailError, CredentialValidationError.emptyEmail);

    cubit.displayNameChanged('Ada');
    expect(cubit.state.displayNameError, isNull);
    expect(cubit.state.emailError, CredentialValidationError.emptyEmail);

    cubit.emailChanged('ada@example.com');
    expect(cubit.state.emailError, isNull);
  });

  test('a short password is the only strength that blocks the form', () async {
    cubit
      ..displayNameChanged('Ada')
      ..emailChanged('ada@example.com')
      ..passwordChanged('abc');

    await cubit.submit();

    expect(cubit.state.passwordError, CredentialValidationError.shortPassword);
    verifyNever(() => signUpWithEmail(any()));
  });

  test('a valid form goes submitting then success and calls the use case', () async {
    when(() => signUpWithEmail(any())).thenAnswer((_) async => const DataSuccess(user));
    fillValidForm();

    final statuses = <SignUpStatus>[];
    final subscription = cubit.stream.listen((s) => statuses.add(s.status));
    await cubit.submit();
    await flush();
    await subscription.cancel();

    expect(statuses, [SignUpStatus.submitting, SignUpStatus.success]);
    verify(() => signUpWithEmail(const SignUpParams(
          displayName: 'Ada Lovelace',
          email: 'ada@example.com',
          password: 'Harbour-lamp-42',
        ))).called(1);
  });

  test('an email already in use surfaces as the failure', () async {
    const failure = Failure.emailAlreadyInUse();
    when(() => signUpWithEmail(any())).thenAnswer((_) async => const DataFailed(failure));
    fillValidForm();

    await cubit.submit();

    expect(cubit.state.status, SignUpStatus.failure);
    expect(cubit.state.failure, failure);
  });

  test('togglePasswordVisibility keeps every error and failure', () async {
    const failure = Failure.emailAlreadyInUse();
    when(() => signUpWithEmail(any())).thenAnswer((_) async => const DataFailed(failure));
    fillValidForm();
    await cubit.submit();

    cubit.togglePasswordVisibility();

    expect(cubit.state.obscurePassword, isFalse);
    expect(cubit.state.failure, failure);
  });

}
