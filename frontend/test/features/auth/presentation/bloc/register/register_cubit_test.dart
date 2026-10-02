import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_error.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/registration_draft.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/register.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/register/register_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/register/register_state.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late MockRegisterUseCase register;
  late RegisterCubit cubit;

  const user = UserEntity(id: 'janeDoeUid', name: 'Jane Doe', email: 'jane@example.com');
  const draft = RegistrationDraftEntity(
    name: 'Jane Doe',
    email: 'jane@example.com',
    password: 'a-long-password',
    passwordConfirmation: 'a-long-password',
  );

  setUpAll(() => registerFallbackValue(const RegistrationDraftEntity()));

  setUp(() {
    register = MockRegisterUseCase();
    cubit = RegisterCubit(register);
  });

  tearDown(() => cubit.close());

  void stubRegisterResult(DataState<UserEntity> result) {
    when(() => register(params: any(named: 'params'))).thenAnswer((_) async => result);
  }

  void fillInForm() {
    cubit
      ..updateName(draft.name)
      ..updateEmail(draft.email)
      ..updatePassword(draft.password)
      ..updatePasswordConfirmation(draft.passwordConfirmation);
  }

  test('starts with an empty form without showing errors', () {
    expect(cubit.state, const RegisterEditing(RegistrationDraftEntity()));
  });

  test('updates every field of the form', () {
    fillInForm();

    expect(cubit.state, const RegisterEditing(draft));
  });

  test('creates the account with what the journalist wrote', () async {
    stubRegisterResult(const DataSuccess(user));
    fillInForm();

    final states = expectLater(
      cubit.stream,
      emitsInOrder([const RegisterInProgress(draft), const RegisterSuccess(draft, user)]),
    );
    await cubit.register();
    await states;
    verify(() => register(params: draft)).called(1);
  });

  test('shows the validation errors when the form breaks a rule', () async {
    stubRegisterResult(const DataFailed(InvalidRegistrationException(RegistrationDraftEntity())));

    await cubit.register();

    expect(cubit.state, const RegisterEditing(RegistrationDraftEntity(), showsValidationErrors: true));
  });

  test('reports why Firebase rejected the account, keeping the form', () async {
    const error = AuthException(AuthError.emailAlreadyInUse);
    stubRegisterResult(const DataFailed(error));
    fillInForm();

    await cubit.register();

    expect(cubit.state, const RegisterFailure(draft, error));
  });
}
