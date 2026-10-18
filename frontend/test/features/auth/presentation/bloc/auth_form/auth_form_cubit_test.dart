import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/shared/users/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/auth_validation.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/delete_account.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_form/auth_form_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_form/auth_form_state.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

const testUser = UserEntity(uid: 'user-1', firstName: 'Jane', lastName: 'Doe', bio: '', role: UserRole.reader);

void main() {
  late MockSignInUseCase signIn;
  late MockSignUpUseCase signUp;
  late MockDeleteAccountUseCase deleteAccount;

  setUpAll(() {
    registerFallbackValue(SignInParams(email: '', password: ''));
    registerFallbackValue(SignUpParams(firstName: '', lastName: '', email: '', password: ''));
  });

  setUp(() {
    signIn = MockSignInUseCase();
    signUp = MockSignUpUseCase();
    deleteAccount = MockDeleteAccountUseCase();
  });

  AuthFormCubit buildCubit() => AuthFormCubit(signIn, signUp, deleteAccount);

  group('signIn', () {
    blocTest<AuthFormCubit, AuthFormState>(
      'submits and succeeds',
      setUp: () => when(() => signIn(any())).thenAnswer((_) async => const DataSuccess(testUser)),
      build: buildCubit,
      act: (cubit) => cubit.signIn(email: 'jane@test.com', password: 'password'),
      expect:
          () => const [AuthFormState(status: AuthFormStatus.submitting), AuthFormState(status: AuthFormStatus.success)],
    );

    blocTest<AuthFormCubit, AuthFormState>(
      'fails with the validation errors',
      setUp:
          () => when(
            () => signIn(any()),
          ).thenAnswer((_) async => const DataFailed(AuthValidationException({AuthValidationError.emailInvalid}))),
      build: buildCubit,
      act: (cubit) => cubit.signIn(email: 'jane', password: 'password'),
      expect:
          () => const [
            AuthFormState(status: AuthFormStatus.submitting),
            AuthFormState(status: AuthFormStatus.failure, validationErrors: {AuthValidationError.emailInvalid}),
          ],
    );

    blocTest<AuthFormCubit, AuthFormState>(
      'fails when the email or the password is wrong',
      setUp: () => when(() => signIn(any())).thenAnswer((_) async => const DataFailed(InvalidCredentialsException())),
      build: buildCubit,
      act: (cubit) => cubit.signIn(email: 'jane@test.com', password: 'wrong'),
      expect:
          () => const [
            AuthFormState(status: AuthFormStatus.submitting),
            AuthFormState(status: AuthFormStatus.failure, failure: AuthFormFailure.invalidCredentials),
          ],
    );

    blocTest<AuthFormCubit, AuthFormState>(
      'fails as unexpected when something else happens',
      setUp: () => when(() => signIn(any())).thenAnswer((_) async => DataFailed(Exception('offline'))),
      build: buildCubit,
      act: (cubit) => cubit.signIn(email: 'jane@test.com', password: 'password'),
      expect:
          () => const [
            AuthFormState(status: AuthFormStatus.submitting),
            AuthFormState(status: AuthFormStatus.failure, failure: AuthFormFailure.unexpected),
          ],
    );
  });

  group('signUp', () {
    blocTest<AuthFormCubit, AuthFormState>(
      'submits the names, email and password',
      setUp: () => when(() => signUp(any())).thenAnswer((_) async => const DataSuccess(testUser)),
      build: buildCubit,
      act: (cubit) => cubit.signUp(firstName: 'Jane', lastName: 'Doe', email: 'jane@test.com', password: 'password'),
      expect:
          () => const [AuthFormState(status: AuthFormStatus.submitting), AuthFormState(status: AuthFormStatus.success)],
      verify: (_) {
        final params = verify(() => signUp(captureAny())).captured.single as SignUpParams;
        expect(params.firstName, 'Jane');
        expect(params.lastName, 'Doe');
      },
    );

    blocTest<AuthFormCubit, AuthFormState>(
      'fails when the email already has an account',
      setUp: () => when(() => signUp(any())).thenAnswer((_) async => const DataFailed(EmailAlreadyInUseException())),
      build: buildCubit,
      act: (cubit) => cubit.signUp(firstName: 'Jane', lastName: 'Doe', email: 'jane@test.com', password: 'password'),
      expect:
          () => const [
            AuthFormState(status: AuthFormStatus.submitting),
            AuthFormState(status: AuthFormStatus.failure, failure: AuthFormFailure.emailAlreadyInUse),
          ],
    );
  });

  group('deleteAccount', () {
    blocTest<AuthFormCubit, AuthFormState>(
      'deletes the account',
      setUp: () => when(() => deleteAccount('password')).thenAnswer((_) async => const DataSuccess(null)),
      build: buildCubit,
      act: (cubit) => cubit.deleteAccount('password'),
      expect:
          () => const [AuthFormState(status: AuthFormStatus.submitting), AuthFormState(status: AuthFormStatus.success)],
    );

    blocTest<AuthFormCubit, AuthFormState>(
      'fails when the password is wrong',
      setUp:
          () => when(
            () => deleteAccount('wrong'),
          ).thenAnswer((_) async => const DataFailed(InvalidCredentialsException())),
      build: buildCubit,
      act: (cubit) => cubit.deleteAccount('wrong'),
      expect:
          () => const [
            AuthFormState(status: AuthFormStatus.submitting),
            AuthFormState(status: AuthFormStatus.failure, failure: AuthFormFailure.invalidCredentials),
          ],
    );
  });
}
