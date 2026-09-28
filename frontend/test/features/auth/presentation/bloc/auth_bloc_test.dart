import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/login_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/logout_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/register_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_bloc.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  LoginUseCase,
  RegisterUseCase,
  LogoutUseCase,
  GetCurrentUserUseCase,
])
void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  const tUser = UserEntity(
    id: 'uid-123',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
  });

  AuthBloc buildBloc() {
    return AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
    );
  }

  test('initial state is AuthInitial', () {
    final bloc = buildBloc();
    expect(bloc.state, const AuthInitial());
    bloc.close();
  });

  group('CheckAuthStatus', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Authenticated] when user is logged in and not anonymous',
      build: () {
        when(mockGetCurrentUserUseCase())
            .thenAnswer((_) async => const DataSuccess(tUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CheckAuthStatus()),
      expect: () => [const Authenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when user is null',
      build: () {
        when(mockGetCurrentUserUseCase())
            .thenAnswer((_) async => const DataSuccess(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CheckAuthStatus()),
      expect: () => [const Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when user is anonymous',
      build: () {
        const anonUser = UserEntity(
          id: 'anon-1',
          email: '',
          isAnonymous: true,
        );
        when(mockGetCurrentUserUseCase())
            .thenAnswer((_) async => const DataSuccess(anonUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CheckAuthStatus()),
      expect: () => [const Unauthenticated()],
    );
  });

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthError] when email is empty',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const LoginRequested(
        email: '',
        password: 'password123',
      )),
      expect: () => [const AuthError('Email cannot be empty.')],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthError] when password is empty',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const LoginRequested(
        email: 'test@example.com',
        password: '',
      )),
      expect: () => [const AuthError('Password cannot be empty.')],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when login succeeds',
      build: () {
        when(mockLoginUseCase(params: anyNamed('params')))
            .thenAnswer((_) async => const DataSuccess(tUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        const AuthLoading(),
        const Authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(mockLoginUseCase(params: anyNamed('params'))).thenAnswer(
            (_) async => const DataGenericFailed('Invalid credentials'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: 'test@example.com',
        password: 'wrongpassword',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError('Failed to SigIn'),
      ],
    );
  });

  group('RegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthError] when email is empty',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const RegisterRequested(
        email: '',
        password: 'password123',
      )),
      expect: () => [const AuthError('Email cannot be empty.')],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthError] when password is less than 6 characters',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const RegisterRequested(
        email: 'test@example.com',
        password: '123',
      )),
      expect: () => [
        const AuthError('Password must be at least 6 characters.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when register succeeds',
      build: () {
        when(mockRegisterUseCase(params: anyNamed('params')))
            .thenAnswer((_) async => const DataSuccess(tUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RegisterRequested(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      )),
      expect: () => [
        const AuthLoading(),
        const Authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when register fails',
      build: () {
        when(mockRegisterUseCase(params: anyNamed('params'))).thenAnswer(
            (_) async => const DataGenericFailed('Email already in use'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RegisterRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError('Failed to register.'),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] on logout',
      build: () {
        when(mockLogoutUseCase())
            .thenAnswer((_) async => const DataSuccess(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );
  });

  group('ClearAuthError', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when in AuthError state',
      build: () => buildBloc(),
      seed: () => const AuthError('Some error'),
      act: (bloc) => bloc.add(const ClearAuthError()),
      expect: () => [const Unauthenticated()],
    );
  });
}
