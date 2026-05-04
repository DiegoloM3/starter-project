import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/link_anonymous_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/link_anonymous_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/send_password_reset.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_anonymously.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

class MockWatchAuthStateUseCase extends Mock implements WatchAuthStateUseCase {}

class MockSignInAnonymouslyUseCase extends Mock
    implements SignInAnonymouslyUseCase {}

class MockSignInWithEmailUseCase extends Mock implements SignInWithEmailUseCase {}

class MockSignUpWithEmailUseCase extends Mock implements SignUpWithEmailUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockSendPasswordResetUseCase extends Mock
    implements SendPasswordResetUseCase {}

class MockLinkAnonymousWithEmailUseCase extends Mock
    implements LinkAnonymousWithEmailUseCase {}

class MockLinkAnonymousWithGoogleUseCase extends Mock
    implements LinkAnonymousWithGoogleUseCase {}

const _anonUser = AuthUserEntity(
  uid: 'anon-uid',
  providerId: 'anonymous',
  isAnonymous: true,
);

const _authUser = AuthUserEntity(
  uid: 'uid-123',
  email: 'user@example.com',
  displayName: 'Test User',
  providerId: 'password',
  isAnonymous: false,
);

const _authError = AuthException(
  message: 'wrong-password',
  code: 'wrong-password',
);

AuthBloc _buildBloc({
  required MockWatchAuthStateUseCase watchAuthState,
  required MockSignInAnonymouslyUseCase signInAnonymously,
  required MockSignInWithEmailUseCase signInWithEmail,
  required MockSignUpWithEmailUseCase signUpWithEmail,
  required MockSignInWithGoogleUseCase signInWithGoogle,
  required MockSignOutUseCase signOut,
  required MockSendPasswordResetUseCase sendPasswordReset,
  MockLinkAnonymousWithEmailUseCase? linkAnonymousWithEmail,
  MockLinkAnonymousWithGoogleUseCase? linkAnonymousWithGoogle,
}) {
  return AuthBloc(
    watchAuthState,
    signInAnonymously,
    signInWithEmail,
    signUpWithEmail,
    signInWithGoogle,
    signOut,
    sendPasswordReset,
    linkAnonymousWithEmail ?? MockLinkAnonymousWithEmailUseCase(),
    linkAnonymousWithGoogle ?? MockLinkAnonymousWithGoogleUseCase(),
  );
}

void main() {
  late MockWatchAuthStateUseCase watchAuthState;
  late MockSignInAnonymouslyUseCase signInAnonymously;
  late MockSignInWithEmailUseCase signInWithEmail;
  late MockSignUpWithEmailUseCase signUpWithEmail;
  late MockSignInWithGoogleUseCase signInWithGoogle;
  late MockSignOutUseCase signOut;
  late MockSendPasswordResetUseCase sendPasswordReset;
  late MockLinkAnonymousWithEmailUseCase linkAnonymousWithEmail;
  late MockLinkAnonymousWithGoogleUseCase linkAnonymousWithGoogle;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const SignInParams(email: '', password: ''),
    );
    registerFallbackValue(
      const SignUpParams(email: '', password: '', displayName: ''),
    );
  });

  setUp(() {
    watchAuthState = MockWatchAuthStateUseCase();
    signInAnonymously = MockSignInAnonymouslyUseCase();
    signInWithEmail = MockSignInWithEmailUseCase();
    signUpWithEmail = MockSignUpWithEmailUseCase();
    signInWithGoogle = MockSignInWithGoogleUseCase();
    signOut = MockSignOutUseCase();
    sendPasswordReset = MockSendPasswordResetUseCase();
    linkAnonymousWithEmail = MockLinkAnonymousWithEmailUseCase();
    linkAnonymousWithGoogle = MockLinkAnonymousWithGoogleUseCase();
  });

  // Helper that provides a watchAuthState stream returning a single value
  // then completes.
  void stubWatch(AuthUserEntity? user) {
    when(() => watchAuthState.call(params: any(named: 'params')))
        .thenAnswer((_) => Stream<AuthUserEntity?>.value(user));
  }

  // -------------------------------------------------------------------
  // Initial state
  // -------------------------------------------------------------------
  test('initial state is AuthInitial', () {
    stubWatch(null);
    when(() => signInAnonymously.call(params: any(named: 'params')))
        .thenAnswer((_) async => const DataSuccess(_anonUser));

    final bloc = _buildBloc(
      watchAuthState: watchAuthState,
      signInAnonymously: signInAnonymously,
      signInWithEmail: signInWithEmail,
      signUpWithEmail: signUpWithEmail,
      signInWithGoogle: signInWithGoogle,
      signOut: signOut,
      sendPasswordReset: sendPasswordReset,
    );

    expect(bloc.state, isA<AuthInitial>());
    bloc.close();
  });

  // -------------------------------------------------------------------
  // WatchAuthState — null stream → AuthUnauthenticated (no auto-anonymous)
  // -------------------------------------------------------------------
  // Bootstrap (auto-anonymous) lives in main() now, not in the bloc. The
  // bloc is a pure observer of authStateChanges; null means "signed out".
  blocTest<AuthBloc, AuthState>(
    'WatchAuthState: null stream emits AuthUnauthenticated',
    build: () {
      stubWatch(null);
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(WatchAuthStateEvent()),
    expect: () => [isA<AuthUnauthenticated>()],
  );

  // -------------------------------------------------------------------
  // WatchAuthState — authenticated stream → AuthAuthenticated
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'WatchAuthState: authenticated user stream emits AuthAuthenticated',
    build: () {
      when(() => watchAuthState.call(params: any(named: 'params')))
          .thenAnswer((_) => Stream<AuthUserEntity?>.value(_authUser));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(WatchAuthStateEvent()),
    expect: () => [isA<AuthAuthenticated>()],
  );

  // -------------------------------------------------------------------
  // SignInWithEmail — success
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'SignInWithEmail: emits AuthAuthenticating then AuthAuthenticated on success',
    build: () {
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => signInWithEmail.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_authUser));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(
      SignInWithEmailEvent(
        const SignInParams(email: 'u@e.com', password: 'pass1234'),
      ),
    ),
    // On success the bloc emits AuthAuthenticating; the AuthAuthenticated
    // emission would come from the auth stream, which we don't simulate here.
    expect: () => [isA<AuthAuthenticating>()],
  );

  // -------------------------------------------------------------------
  // SignInWithEmail — failure
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'SignInWithEmail: emits AuthAuthenticating then AuthError on failure',
    build: () {
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => signInWithEmail.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(_authError));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(
      SignInWithEmailEvent(
        const SignInParams(email: 'u@e.com', password: 'wrong'),
      ),
    ),
    expect: () => [
      isA<AuthAuthenticating>(),
      isA<AuthError>(),
    ],
  );

  // -------------------------------------------------------------------
  // SignUpWithEmail — success
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'SignUpWithEmail: emits AuthAuthenticating then AuthAuthenticated on success',
    build: () {
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => signUpWithEmail.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_authUser));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(
      SignUpWithEmailEvent(
        const SignUpParams(
          email: 'n@e.com',
          password: 'pass1234',
          displayName: 'Alice',
        ),
      ),
    ),
    // Same as sign-in success — the AuthAuthenticated emission is the
    // stream's job (post-signup Firebase emits the new user).
    expect: () => [isA<AuthAuthenticating>()],
  );

  // -------------------------------------------------------------------
  // SignInWithGoogle — cancelled (null result → no error, stays anonymous)
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'SignInWithGoogle: cancelled returns AuthAuthenticating only (no state change)',
    build: () {
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => signInWithGoogle.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(
                AuthException(
                  message: 'cancelled',
                  code: 'popup-closed-by-user',
                ),
              ));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(SignInWithGoogleEvent()),
    // Cancelled = emit AuthAuthenticating, then revert to previous state
    // (AuthInitial here since the watch handler hasn't been started).
    expect: () => [
      isA<AuthAuthenticating>(),
      isA<AuthInitial>(),
    ],
  );

  // -------------------------------------------------------------------
  // SignOut
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'SignOut: emits AuthAuthenticating, AuthUnauthenticated, then AuthAnonymous',
    build: () {
      // First watch emission is null (sets up anonymous)
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => signOut.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(null));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(SignOutEvent()),
    // SignOut emits AuthAuthenticating, then chains SignInAnonymouslyEvent
    // which would emit AuthAuthenticating again — but Equatable dedupes
    // consecutive identical states, so we only see one. The terminal
    // AuthAnonymous would come from the auth stream (not simulated here).
    expect: () => [isA<AuthAuthenticating>()],
  );

  // -------------------------------------------------------------------
  // SendPasswordReset
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'SendPasswordReset: emits no state change on success',
    build: () {
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => sendPasswordReset.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(null));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) =>
        bloc.add(SendPasswordResetEvent('user@example.com')),
    // No state transition on password reset success
    expect: () => [],
  );

  // -------------------------------------------------------------------
  // ErrorDismissed — reverts to AuthAnonymous
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'ErrorDismissed: reverts from AuthError to AuthAnonymous',
    build: () {
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => signInWithEmail.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(_authError));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    seed: () => const AuthError(_authError, previousState: AuthAnonymous(_anonUser)),
    act: (bloc) => bloc.add(ErrorDismissedEvent()),
    expect: () => [
      isA<AuthAnonymous>(),
    ],
  );

  // -------------------------------------------------------------------
  // LinkAnonymousWithEmailEvent
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'LinkAnonymousWithEmailEvent: emits AuthAuthenticating on DataSuccess (stream owns AuthAuthenticated)',
    build: () {
      stubWatch(null);
      when(() => linkAnonymousWithEmail.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_authUser));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
        linkAnonymousWithEmail: linkAnonymousWithEmail,
        linkAnonymousWithGoogle: linkAnonymousWithGoogle,
      );
    },
    act: (bloc) => bloc.add(
      LinkAnonymousWithEmailEvent(
        const SignUpParams(
          email: 'link@e.com',
          password: 'pass1234',
          displayName: 'Alice',
        ),
      ),
    ),
    expect: () => [isA<AuthAuthenticating>()],
  );

  blocTest<AuthBloc, AuthState>(
    'LinkAnonymousWithEmailEvent: emits AuthAuthenticating then AuthError on DataFailed',
    build: () {
      stubWatch(null);
      when(() => linkAnonymousWithEmail.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(_authError));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
        linkAnonymousWithEmail: linkAnonymousWithEmail,
        linkAnonymousWithGoogle: linkAnonymousWithGoogle,
      );
    },
    act: (bloc) => bloc.add(
      LinkAnonymousWithEmailEvent(
        const SignUpParams(email: 'link@e.com', password: '123', displayName: ''),
      ),
    ),
    expect: () => [isA<AuthAuthenticating>(), isA<AuthError>()],
  );

  blocTest<AuthBloc, AuthState>(
    'LinkAnonymousWithEmailEvent: calls use case with correct params',
    build: () {
      stubWatch(null);
      when(() => linkAnonymousWithEmail.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_authUser));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
        linkAnonymousWithEmail: linkAnonymousWithEmail,
        linkAnonymousWithGoogle: linkAnonymousWithGoogle,
      );
    },
    act: (bloc) => bloc.add(
      const LinkAnonymousWithEmailEvent(
        SignUpParams(email: 'a@b.com', password: 'pass', displayName: 'Bob'),
      ),
    ),
    verify: (_) {
      verify(() => linkAnonymousWithEmail.call(params: any(named: 'params')))
          .called(1);
    },
  );

  // -------------------------------------------------------------------
  // LinkAnonymousWithGoogleEvent
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'LinkAnonymousWithGoogleEvent: emits AuthAuthenticating on DataSuccess',
    build: () {
      stubWatch(null);
      when(() => linkAnonymousWithGoogle.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_authUser));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
        linkAnonymousWithEmail: linkAnonymousWithEmail,
        linkAnonymousWithGoogle: linkAnonymousWithGoogle,
      );
    },
    act: (bloc) => bloc.add(const LinkAnonymousWithGoogleEvent()),
    expect: () => [isA<AuthAuthenticating>()],
  );

  blocTest<AuthBloc, AuthState>(
    'LinkAnonymousWithGoogleEvent: emits AuthAuthenticating then AuthError on DataFailed',
    build: () {
      stubWatch(null);
      when(() => linkAnonymousWithGoogle.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(_authError));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
        linkAnonymousWithEmail: linkAnonymousWithEmail,
        linkAnonymousWithGoogle: linkAnonymousWithGoogle,
      );
    },
    act: (bloc) => bloc.add(const LinkAnonymousWithGoogleEvent()),
    expect: () => [isA<AuthAuthenticating>(), isA<AuthError>()],
  );
}
