import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/change_password.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/forgot_password.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

import '../../../../mocks/mocks.dart';
import '../../../../fixtures/test_fixtures.dart';

// Manual mock for ChangePasswordUseCase until mocks are regenerated
class MockChangePasswordUseCase extends Mock implements ChangePasswordUseCase {}

// Manual mock for ForgotPasswordUseCase until mocks are regenerated
class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockSignInUseCase mockSignInUseCase;
  late MockSignUpUseCase mockSignUpUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockGetAuthStateChangesUseCase mockGetAuthStateChangesUseCase;
  late MockChangePasswordUseCase mockChangePasswordUseCase;
  late MockForgotPasswordUseCase mockForgotPasswordUseCase;

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockSignUpUseCase = MockSignUpUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockGetAuthStateChangesUseCase = MockGetAuthStateChangesUseCase();
    mockChangePasswordUseCase = MockChangePasswordUseCase();
    mockForgotPasswordUseCase = MockForgotPasswordUseCase();

    // Setup default stream for auth state changes
    when(mockGetAuthStateChangesUseCase.call())
        .thenAnswer((_) => Stream<UserEntity?>.empty());

    authBloc = AuthBloc(
      signInUseCase: mockSignInUseCase,
      signUpUseCase: mockSignUpUseCase,
      signOutUseCase: mockSignOutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      getAuthStateChangesUseCase: mockGetAuthStateChangesUseCase,
      changePasswordUseCase: mockChangePasswordUseCase,
      forgotPasswordUseCase: mockForgotPasswordUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  final testUser = TestFixtures.testUser;

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    group('CheckAuthStatus', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when user is logged in',
        build: () {
          when(mockGetCurrentUserUseCase.call())
              .thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(const CheckAuthStatus()),
        expect: () => [
          isA<AuthLoading>(),
          isA<Authenticated>(),
        ],
        verify: (_) {
          verify(mockGetCurrentUserUseCase.call()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when no user is logged in',
        build: () {
          when(mockGetCurrentUserUseCase.call()).thenAnswer((_) async => null);
          return authBloc;
        },
        act: (bloc) => bloc.add(const CheckAuthStatus()),
        expect: () => [
          isA<AuthLoading>(),
          isA<Unauthenticated>(),
        ],
      );
    });

    group('SignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when sign in succeeds',
        build: () {
          when(mockSignInUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataSuccess(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested(
          email: 'test@example.com',
          password: 'password123',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<Authenticated>(),
        ],
        verify: (_) {
          verify(mockSignInUseCase.call(
            params: argThat(
              isA<SignInParams>(),
              named: 'params',
            ),
          )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails',
        build: () {
          when(mockSignInUseCase.call(params: anyNamed('params'))).thenAnswer(
              (_) async =>
                  DataFailed(Exception('user-not-found: User not found')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested(
          email: 'test@example.com',
          password: 'wrongpassword',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'maps error correctly to AuthFailure.userNotFound',
        build: () {
          when(mockSignInUseCase.call(params: anyNamed('params'))).thenAnswer(
              (_) async =>
                  DataFailed(Exception('user-not-found: User not found')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested(
          email: 'test@example.com',
          password: 'password',
        )),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<AuthError>());
          expect((state as AuthError).failure, AuthFailure.userNotFound);
        },
      );
    });

    group('SignUpRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when sign up succeeds',
        build: () {
          when(mockSignUpUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataSuccess(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignUpRequested(
          email: 'new@example.com',
          password: 'password123',
          displayName: 'New User',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<Authenticated>(),
        ],
        verify: (_) {
          verify(mockSignUpUseCase.call(
            params: argThat(
              isA<SignUpParams>(),
              named: 'params',
            ),
          )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign up fails',
        build: () {
          when(mockSignUpUseCase.call(params: anyNamed('params'))).thenAnswer(
              (_) async => DataFailed(
                  Exception('email-already-in-use: Email already exists')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignUpRequested(
          email: 'existing@example.com',
          password: 'password123',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'maps error correctly to AuthFailure.emailAlreadyInUse',
        build: () {
          when(mockSignUpUseCase.call(params: anyNamed('params'))).thenAnswer(
              (_) async => DataFailed(
                  Exception('email-already-in-use: Email already exists')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignUpRequested(
          email: 'existing@example.com',
          password: 'password123',
        )),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<AuthError>());
          expect((state as AuthError).failure, AuthFailure.emailAlreadyInUse);
        },
      );
    });

    group('SignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when sign out succeeds',
        build: () {
          when(mockSignOutUseCase.call()).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignOutRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<Unauthenticated>(),
        ],
        verify: (_) {
          verify(mockSignOutUseCase.call()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign out fails',
        build: () {
          when(mockSignOutUseCase.call())
              .thenThrow(Exception('Sign out failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignOutRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('AuthStateChanged', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Authenticated] when isAuthenticated is true and user exists',
        build: () {
          when(mockGetCurrentUserUseCase.call())
              .thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthStateChanged(isAuthenticated: true)),
        expect: () => [
          isA<Authenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] when isAuthenticated is false',
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthStateChanged(isAuthenticated: false)),
        expect: () => [
          isA<Unauthenticated>(),
        ],
      );
    });

    group('Error Mapping', () {
      blocTest<AuthBloc, AuthState>(
        'maps "invalid-email" to AuthFailure.invalidEmail',
        build: () {
          when(mockSignInUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataFailed(Exception('invalid-email')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested(
          email: 'test@example.com',
          password: 'password',
        )),
        verify: (bloc) {
          expect(bloc.state, isA<AuthError>());
          expect((bloc.state as AuthError).failure, AuthFailure.invalidEmail);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'maps "wrong-password" to AuthFailure.wrongPassword',
        build: () {
          when(mockSignInUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataFailed(Exception('wrong-password')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested(
          email: 'test@example.com',
          password: 'password',
        )),
        verify: (bloc) {
          expect(bloc.state, isA<AuthError>());
          expect((bloc.state as AuthError).failure, AuthFailure.wrongPassword);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'maps "user-not-found" to AuthFailure.userNotFound',
        build: () {
          when(mockSignInUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataFailed(Exception('user-not-found')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested(
          email: 'test@example.com',
          password: 'password',
        )),
        verify: (bloc) {
          expect(bloc.state, isA<AuthError>());
          expect((bloc.state as AuthError).failure, AuthFailure.userNotFound);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'maps "email-already-in-use" to AuthFailure.emailAlreadyInUse',
        build: () {
          when(mockSignInUseCase.call(params: anyNamed('params'))).thenAnswer(
              (_) async => DataFailed(Exception('email-already-in-use')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested(
          email: 'test@example.com',
          password: 'password',
        )),
        verify: (bloc) {
          expect(bloc.state, isA<AuthError>());
          expect(
              (bloc.state as AuthError).failure, AuthFailure.emailAlreadyInUse);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'maps "weak-password" to AuthFailure.weakPassword',
        build: () {
          when(mockSignInUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataFailed(Exception('weak-password')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested(
          email: 'test@example.com',
          password: 'password',
        )),
        verify: (bloc) {
          expect(bloc.state, isA<AuthError>());
          expect((bloc.state as AuthError).failure, AuthFailure.weakPassword);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'maps unknown error to AuthFailure.unknown',
        build: () {
          when(mockSignInUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataFailed(Exception('unknown error')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested(
          email: 'test@example.com',
          password: 'password',
        )),
        verify: (bloc) {
          expect(bloc.state, isA<AuthError>());
          expect((bloc.state as AuthError).failure, AuthFailure.unknown);
        },
      );
    });
  });
}
