import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/auth_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/create_user_params.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/sign_in_with_email_and_password_params.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/login/domain/usecases/create_user.dart';
import 'package:news_app_clean_architecture/features/login/domain/usecases/login_stream.dart';
import 'package:news_app_clean_architecture/features/login/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:news_app_clean_architecture/features/login/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_bloc.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_field_error.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/register_field_error.dart';

class MockLoginStreamUseCase extends Mock implements LoginStreamUseCase {}

class MockSignInWithEmailAndPasswordUseCase extends Mock
    implements SignInWithEmailAndPasswordUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockCreateUserUseCase extends Mock implements CreateUserUseCase {}

void main() {
  late MockLoginStreamUseCase mockLoginStreamUseCase;
  late MockSignInWithEmailAndPasswordUseCase
      mockSignInWithEmailAndPasswordUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockCreateUserUseCase mockCreateUserUseCase;

  const tUser = UserEntity(
    id: '1',
    email: 'test@test.com',
    name: 'Test User',
    profilePictureUrl: '',
  );

  const tValidPassword = 'Password123!';

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(const SignInWithEmailAndPasswordParams(
      email: 'test@test.com',
      password: 'test',
    ));
    registerFallbackValue(const CreateUserParams(
      user: tUser,
      password: tValidPassword,
    ));
  });

  setUp(() {
    mockLoginStreamUseCase = MockLoginStreamUseCase();
    mockSignInWithEmailAndPasswordUseCase =
        MockSignInWithEmailAndPasswordUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    mockCreateUserUseCase = MockCreateUserUseCase();
  });

  LoginBloc buildBloc() {
    return LoginBloc(
      mockLoginStreamUseCase,
      mockCreateUserUseCase,
      mockSignInWithEmailAndPasswordUseCase,
      mockSignOutUseCase,
    );
  }

  group('LoginBloc Tests', () {
    group('Initial State & StartWatchingUser', () {
      blocTest<LoginBloc, LoginState>(
        'Should emit LoggedIn when user stream returns a user upon initialization',
        build: () {
          when(() => mockLoginStreamUseCase.call(any()))
              .thenAnswer((_) => Stream.value(tUser));
          return buildBloc();
        },
        expect: () => [
          const LoggedIn(user: tUser),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'Should emit NotLoggedIn when user stream returns null upon initialization',
        build: () {
          when(() => mockLoginStreamUseCase.call(any()))
              .thenAnswer((_) => Stream.value(null));
          return buildBloc();
        },
        expect: () => [
          const NotLoggedIn(),
        ],
      );
    });

    group('SignInWithEmailAndPasswordRequested', () {
      blocTest<LoginBloc, LoginState>(
        'Should emit NotLoggedIn with loginErrors when validation fails',
        build: () {
          when(() => mockLoginStreamUseCase.call(any()))
              .thenAnswer((_) => const Stream.empty());
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          SignInWithEmailAndPasswordRequested(
            email: 'invalid',
            password: '',
          ),
        ),
        expect: () => [
          const NotLoggedIn(
            loginErrors: [
              LoginFieldError.emailNotValid,
              LoginFieldError.passwordNotValid,
              LoginFieldError.passwordRequired,
            ],
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'Should emit [LoginLoading, LoggedIn] when sign in is successful',
        build: () {
          when(() => mockLoginStreamUseCase.call(any()))
              .thenAnswer((_) => const Stream.empty());
          when(() => mockSignInWithEmailAndPasswordUseCase(any()))
              .thenAnswer((_) async => const DataSuccess(tUser));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          SignInWithEmailAndPasswordRequested(
            email: 'test@test.com',
            password: tValidPassword,
          ),
        ),
        expect: () => [
          const LoginLoading(),
          const LoggedIn(user: tUser),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'Should emit [LoginLoading, NotLoggedIn] with invalidCredentials when InvalidCredentialException occurs',
        build: () {
          when(() => mockLoginStreamUseCase.call(any()))
              .thenAnswer((_) => const Stream.empty());
          when(() => mockSignInWithEmailAndPasswordUseCase(any())).thenAnswer(
            (_) async => const DataFailed(InvalidCredentialException()),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          SignInWithEmailAndPasswordRequested(
            email: 'test@test.com',
            password: tValidPassword,
          ),
        ),
        expect: () => [
          const LoginLoading(),
          const NotLoggedIn(
            loginErrors: [LoginFieldError.invalidCredentials],
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'Should emit [LoginLoading, LoginError] when a generic error occurs during sign in',
        build: () {
          when(() => mockLoginStreamUseCase.call(any()))
              .thenAnswer((_) => const Stream.empty());
          when(() => mockSignInWithEmailAndPasswordUseCase(any())).thenAnswer(
            (_) async => DataFailed(Exception('Unexpected error')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          SignInWithEmailAndPasswordRequested(
            email: 'test@test.com',
            password: tValidPassword,
          ),
        ),
        expect: () => [
          const LoginLoading(),
          isA<LoginError>(),
        ],
      );
    });

    group('CreateUserRequested', () {
      blocTest<LoginBloc, LoginState>(
        'Should emit NotLoggedIn with registerErrors when validation fails',
        build: () {
          when(() => mockLoginStreamUseCase.call(any()))
              .thenAnswer((_) => const Stream.empty());
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          CreateUserRequested(
            user: const UserEntity(
                id: '', email: '', name: '', profilePictureUrl: ''),
            password: '',
          ),
        ),
        expect: () => [
          const NotLoggedIn(
            registerErrors: [
              RegisterFieldError.nameRequired,
              RegisterFieldError.emailNotValid,
              RegisterFieldError.emailRequired,
              RegisterFieldError.passwordNotValid,
              RegisterFieldError.passwordRequired,
            ],
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'Should emit [LoginLoading] when registration use case is successful',
        build: () {
          when(() => mockLoginStreamUseCase.call(any()))
              .thenAnswer((_) => const Stream.empty());
          when(() => mockCreateUserUseCase(any()))
              .thenAnswer((_) async => const DataSuccess(tUser));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          CreateUserRequested(
            user: tUser,
            password: tValidPassword,
          ),
        ),
        expect: () => [
          const LoginLoading(),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'Should emit [LoginLoading, NotLoggedIn] with emailAlreadyRegistered when EmailAlreadyInUseException occurs',
        build: () {
          when(() => mockLoginStreamUseCase.call(any()))
              .thenAnswer((_) => const Stream.empty());
          when(() => mockCreateUserUseCase(any())).thenAnswer(
            (_) async => const DataFailed(EmailAlreadyInUseException()),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          CreateUserRequested(
            user: tUser,
            password: tValidPassword,
          ),
        ),
        expect: () => [
          const LoginLoading(),
          const NotLoggedIn(
            registerErrors: [RegisterFieldError.emailAlreadyRegistered],
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'Should emit [LoginLoading, LoginError] when a generic error occurs during registration',
        build: () {
          when(() => mockLoginStreamUseCase.call(any()))
              .thenAnswer((_) => const Stream.empty());
          when(() => mockCreateUserUseCase(any())).thenAnswer(
            (_) async => DataFailed(Exception('Registration failed')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          CreateUserRequested(
            user: tUser,
            password: tValidPassword,
          ),
        ),
        expect: () => [
          const LoginLoading(),
          isA<LoginError>(),
        ],
      );
    });

    group('SignOutRequested', () {
      blocTest<LoginBloc, LoginState>(
        'Should emit NotLoggedIn when sign out is successful',
        build: () {
          when(() => mockLoginStreamUseCase.call(any()))
              .thenAnswer((_) => Stream.value(tUser));
          when(() => mockSignOutUseCase(any()))
              .thenAnswer((_) async => const DataSuccess(null));
          return buildBloc();
        },
        act: (bloc) => bloc.add(SignOutRequested()),
        skip: 1, 
        expect: () => [
          const NotLoggedIn(),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'Should emit LoginError when sign out fails',
        build: () {
          when(() => mockLoginStreamUseCase.call(any()))
              .thenAnswer((_) => Stream.value(tUser));
          when(() => mockSignOutUseCase(any())).thenAnswer(
            (_) async => DataFailed(Exception('Sign out failed')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(SignOutRequested()),
        skip: 1, 
        expect: () => [
          isA<LoginError>(),
        ],
      );
    });
  });
}
