import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/auth/domain/use_cases/check_auth_use_case.dart';
import 'package:tortutip/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:tortutip/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_event.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_state.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class MockCheckAuthUseCase extends Mock implements CheckAuthUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

void main() {
  late AuthBloc bloc;
  late MockCheckAuthUseCase mockCheckAuth;
  late MockSignInWithGoogleUseCase mockSignIn;
  late MockSignOutUseCase mockSignOut;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockCheckAuth = MockCheckAuthUseCase();
    mockSignIn = MockSignInWithGoogleUseCase();
    mockSignOut = MockSignOutUseCase();
    bloc = AuthBloc(
      mockCheckAuth,
      mockSignIn,
      mockSignOut,
    );
  });

  tearDown(() => bloc.close());

  final tUser = UserEntity(
    id: 'user_1',
    name: 'Test User',
    email: 'test@example.com',
    avatarUrl: '',
    bio: '',
    role: 'reader',
    gender: '',
    ageRange: '',
    createdAt: DateTime(2024),
  );

  group('CheckAuthEvent', () {
    blocTest<AuthBloc, AuthState>(
      'should_emit_Loading_then_Authenticated_when_user_exists',
      build: () {
        when(() => mockCheckAuth(any()))
            .thenAnswer((_) async => DataSuccess(tUser));
        return bloc;
      },
      act: (b) => b.add(const CheckAuthEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should_emit_Loading_then_Initial_when_no_active_session',
      build: () {
        when(() => mockCheckAuth(any()))
            .thenAnswer((_) async => DataFailed(Exception('No active session')));
        return bloc;
      },
      act: (b) => b.add(const CheckAuthEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthInitial>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should_emit_Loading_then_Initial_when_check_fails',
      build: () {
        when(() => mockCheckAuth(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        return bloc;
      },
      act: (b) => b.add(const CheckAuthEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthInitial>(),
      ],
    );
  });

  group('SignInWithGoogleEvent', () {
    blocTest<AuthBloc, AuthState>(
      'should_emit_Loading_then_Authenticated_when_sign_in_succeeds',
      build: () {
        when(() => mockSignIn(any()))
            .thenAnswer((_) async => DataSuccess(tUser));
        return bloc;
      },
      act: (b) => b.add(const SignInWithGoogleEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should_emit_Loading_then_Error_when_sign_in_fails',
      build: () {
        when(() => mockSignIn(any()))
            .thenAnswer((_) async => DataFailed(Exception('Network error')));
        return bloc;
      },
      act: (b) => b.add(const SignInWithGoogleEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
      verify: (b) {
        final state = b.state as AuthError;
        expect(state.message, isNotEmpty);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'should_emit_Loading_then_Error_with_empty_message_when_user_cancels',
      build: () {
        when(() => mockSignIn(any())).thenAnswer(
            (_) async => DataFailed(Exception('Sign in cancelled by user')));
        return bloc;
      },
      act: (b) => b.add(const SignInWithGoogleEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
      verify: (b) {
        final state = b.state as AuthError;
        expect(state.message, isEmpty);
      },
    );
  });

  group('SignOutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'should_emit_Initial_after_sign_out',
      build: () {
        when(() => mockSignOut(any()))
            .thenAnswer((_) async => const DataSuccess(true));
        return bloc;
      },
      act: (b) => b.add(const SignOutEvent()),
      expect: () => [
        isA<AuthInitial>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should_emit_Error_when_sign_out_fails',
      build: () {
        when(() => mockSignOut(any()))
            .thenAnswer((_) async => DataFailed(Exception('sign out error')));
        return bloc;
      },
      act: (b) => b.add(const SignOutEvent()),
      expect: () => [
        isA<AuthError>(),
      ],
    );
  });
}
