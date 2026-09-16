import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_in/sign_in_cubit.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const SignInParams(email: '', password: ''));
  });

  late MockSignInWithEmailUseCase signInWithEmail;
  late MockSignInWithGoogleUseCase signInWithGoogle;
  late SignInCubit cubit;

  setUp(() {
    signInWithEmail = MockSignInWithEmailUseCase();
    signInWithGoogle = MockSignInWithGoogleUseCase();
    cubit = SignInCubit(signInWithEmail, signInWithGoogle);
  });
  tearDown(() => cubit.close());

  void fillValidForm() {
    cubit
      ..emailChanged('ada@example.com')
      ..passwordChanged('secret123');
  }

  test('typing updates the field and drops that field\'s own error only', () async {
    await cubit.submit();
    expect(cubit.state.emailError, CredentialValidationError.emptyEmail);
    expect(cubit.state.passwordError, CredentialValidationError.emptyPassword);

    cubit.emailChanged('ada@example.com');

    expect(cubit.state.email, 'ada@example.com');
    expect(cubit.state.emailError, isNull);
    expect(cubit.state.passwordError, CredentialValidationError.emptyPassword);
    expect(cubit.state.status, SignInStatus.editing);
  });

  test('togglePasswordVisibility flips the flag and keeps errors', () async {
    await cubit.submit();

    cubit.togglePasswordVisibility();

    expect(cubit.state.obscurePassword, isFalse);
    expect(cubit.state.emailError, CredentialValidationError.emptyEmail);
  });

  test('submit with an invalid form reports field errors without calling the use case', () async {
    cubit.emailChanged('not-an-email');

    await cubit.submit();

    expect(cubit.state.status, SignInStatus.failure);
    expect(cubit.state.emailError, CredentialValidationError.invalidEmail);
    expect(cubit.state.passwordError, CredentialValidationError.emptyPassword);
    verifyNever(() => signInWithEmail(any()));
  });

  test('submit with a valid form goes submitting, then success', () async {
    when(() => signInWithEmail(any())).thenAnswer((_) async => const DataSuccess(user));
    fillValidForm();

    final statuses = <SignInStatus>[];
    final subscription = cubit.stream.listen((s) => statuses.add(s.status));
    await cubit.submit();
    await flush();
    await subscription.cancel();

    expect(statuses, [SignInStatus.submitting, SignInStatus.success]);
    verify(() => signInWithEmail(
          const SignInParams(email: 'ada@example.com', password: 'secret123'),
        )).called(1);
  });

  test('a rejected attempt ends in failure carrying the provider failure', () async {
    const failure = Failure.invalidCredentials();
    when(() => signInWithEmail(any())).thenAnswer((_) async => const DataFailed(failure));
    fillValidForm();

    await cubit.submit();

    expect(cubit.state.status, SignInStatus.failure);
    expect(cubit.state.failure, failure);
    expect(cubit.state.emailError, isNull);
  });

  test('signInWithGoogle succeeds without touching the form', () async {
    when(() => signInWithGoogle(any())).thenAnswer((_) async => const DataSuccess(user));

    await cubit.signInWithGoogle();

    expect(cubit.state.status, SignInStatus.success);
    expect(cubit.state.email, isEmpty);
  });

  test('a cancelled Google picker is reported as a failure', () async {
    when(() => signInWithGoogle(any()))
        .thenAnswer((_) async => const DataFailed(Failure.cancelled()));

    await cubit.signInWithGoogle();

    expect(cubit.state.failure?.type, FailureType.cancelled);
  });

  test('submit is ignored while another attempt is in flight', () async {
    final gate = Completer<DataState<UserEntity>>();
    when(() => signInWithEmail(any())).thenAnswer((_) => gate.future);
    fillValidForm();

    final first = cubit.submit();
    await cubit.submit();
    await cubit.signInWithGoogle();
    gate.complete(const DataSuccess(user));
    await first;

    verify(() => signInWithEmail(any())).called(1);
    verifyNever(() => signInWithGoogle(any()));
  });

  test('a result arriving after close is dropped', () async {
    final gate = Completer<DataState<UserEntity>>();
    when(() => signInWithEmail(any())).thenAnswer((_) => gate.future);
    fillValidForm();

    final pending = cubit.submit();
    await cubit.close();
    gate.complete(const DataSuccess(user));
    await pending;

    expect(cubit.state.status, SignInStatus.submitting);
  });
}
