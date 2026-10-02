import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_error.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_in/sign_in_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_in/sign_in_state.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}

void main() {
  late MockSignInUseCase signIn;
  late SignInCubit cubit;

  const user = UserEntity(id: 'janeDoeUid', name: 'Jane Doe', email: 'jane@example.com');
  const params = SignInParams(email: 'jane@example.com', password: 'a-long-password');

  setUpAll(() => registerFallbackValue(const SignInParams()));

  setUp(() {
    signIn = MockSignInUseCase();
    cubit = SignInCubit(signIn);
  });

  tearDown(() => cubit.close());

  void stubSignInResult(DataState<UserEntity> result) {
    when(() => signIn(params: any(named: 'params'))).thenAnswer((_) async => result);
  }

  void fillInForm() {
    cubit
      ..updateEmail(params.email)
      ..updatePassword(params.password);
  }

  test('starts with an empty form without showing errors', () {
    expect(cubit.state, const SignInEditing(SignInParams()));
  });

  test('updates the email and password', () {
    fillInForm();

    expect(cubit.state, const SignInEditing(params));
  });

  test('signs in with what the journalist wrote', () async {
    stubSignInResult(const DataSuccess(user));
    fillInForm();

    final states = expectLater(
      cubit.stream,
      emitsInOrder([const SignInInProgress(params), const SignInSuccess(params, user)]),
    );
    await cubit.signIn();
    await states;
    verify(() => signIn(params: params)).called(1);
  });

  test('shows the validation errors when the form is incomplete, and keeps them while editing', () async {
    stubSignInResult(const DataFailed(InvalidSignInException(SignInParams())));

    await cubit.signIn();
    expect(cubit.state, const SignInEditing(SignInParams(), showsValidationErrors: true));

    cubit.updateEmail('jane@example.com');
    expect(cubit.state, const SignInEditing(SignInParams(email: 'jane@example.com'), showsValidationErrors: true));
  });

  test('reports why Firebase rejected the sign-in, keeping the form', () async {
    const error = AuthException(AuthError.wrongEmailOrPassword);
    stubSignInResult(const DataFailed(error));
    fillInForm();

    await cubit.signIn();

    expect(cubit.state, const SignInFailure(params, error));
  });
}
