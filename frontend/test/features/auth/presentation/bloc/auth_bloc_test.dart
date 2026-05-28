import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/register_fallback_values.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late AuthBloc bloc;
  late MockSignInUseCase mockSignIn;
  late MockSignUpUseCase mockSignUp;
  late MockSignOutUseCase mockSignOut;
  late MockGetAuthStateChangesUseCase mockGetAuthStateChanges;
  late StreamController<AuthUserEntity?> authStreamController;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockSignIn = MockSignInUseCase();
    mockSignUp = MockSignUpUseCase();
    mockSignOut = MockSignOutUseCase();
    mockGetAuthStateChanges = MockGetAuthStateChangesUseCase();
    authStreamController = StreamController<AuthUserEntity?>();

    when(() => mockGetAuthStateChanges())
        .thenAnswer((_) => authStreamController.stream);

    bloc = AuthBloc(mockSignIn, mockSignUp, mockSignOut, mockGetAuthStateChanges);
  });

  tearDown(() async {
    await bloc.close();
    await authStreamController.close();
  });

  group('initial state', () {
    test('is AuthInitial', () {
      expect(bloc.state, isA<AuthInitial>());
    });
  });

  group('authStateChanges stream', () {
    test('emits Authenticated when stream yields user', () async {
      final user = testAuthUser();

      authStreamController.add(user);
      await expectLater(
        bloc.stream,
        emits(isA<AuthAuthenticated>()),
      );

      final state = bloc.state as AuthAuthenticated;
      expect(state.user!.uid, tUserId);
      expect(state.user!.email, tEmail);
    });

    test('emits Unauthenticated when stream yields null', () async {
      authStreamController.add(null);
      await expectLater(
        bloc.stream,
        emits(isA<AuthUnauthenticated>()),
      );
    });
  });

  group('AuthSignInRequested', () {
    test('emits [Loading] then Authenticated via auth stream on success',
        () async {
      final user = testAuthUser();
      when(() => mockSignIn(params: any(named: 'params')))
          .thenAnswer((_) async {
        authStreamController.add(user);
        return DataSuccess(user);
      });

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthSignInRequested(
        email: tEmail,
        password: tPassword,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthAuthenticated>());
      expect((states[1] as AuthAuthenticated).user!.uid, tUserId);

      verify(() => mockSignIn(params: any(named: 'params'))).called(1);

      await sub.cancel();
    });

    test('emits [Loading, Failure] on sign in error', () async {
      const error = AuthException(
        message: 'Invalid credentials',
        code: 'wrong-password',
      );
      when(() => mockSignIn(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(error));

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthSignInRequested(
        email: tEmail,
        password: tPassword,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthFailure>());
      expect((states[1] as AuthFailure).error!.message, 'Invalid credentials');
      expect((states[1] as AuthFailure).error!.code, 'wrong-password');

      await sub.cancel();
    });
  });

  group('AuthSignUpRequested', () {
    test('emits [Loading] then Authenticated via auth stream on success',
        () async {
      final user = testAuthUser();
      when(() => mockSignUp(params: any(named: 'params')))
          .thenAnswer((_) async {
        authStreamController.add(user);
        return DataSuccess(user);
      });

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthSignUpRequested(
        email: tEmail,
        password: tPassword,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthAuthenticated>());

      verify(() => mockSignUp(params: any(named: 'params'))).called(1);

      await sub.cancel();
    });

    test('emits [Loading, Failure] on sign up error', () async {
      const error = AuthException(
        message: 'Email in use',
        code: 'email-already-in-use',
      );
      when(() => mockSignUp(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(error));

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthSignUpRequested(
        email: tEmail,
        password: tPassword,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthFailure>());
      expect((states[1] as AuthFailure).error!.code, 'email-already-in-use');

      await sub.cancel();
    });
  });

  group('AuthSignOutRequested', () {
    test('emits [Loading] then Unauthenticated via auth stream on success',
        () async {
      when(() => mockSignOut()).thenAnswer((_) async {
        authStreamController.add(null);
        return const DataSuccess(null);
      });

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthSignOutRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthUnauthenticated>());

      verify(() => mockSignOut()).called(1);

      await sub.cancel();
    });

    test('emits [Loading, Failure] on sign out error', () async {
      const error = AuthException(message: 'fail', code: 'err');
      when(() => mockSignOut())
          .thenAnswer((_) async => const DataFailed(error));

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthSignOutRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthFailure>());

      await sub.cancel();
    });
  });

  group('close', () {
    test('cancels auth stream subscription', () async {
      await bloc.close();
      // Should not throw when adding to the controller after close
      authStreamController.add(testAuthUser());
    });
  });
}
