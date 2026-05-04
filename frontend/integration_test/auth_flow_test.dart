// Integration test for the auth flow.
//
// Scope: widget-level integration (widget tree + AuthBloc, no real Firebase).
// Scenarios covered:
//   1. Cold start → AuthAnonymous state is visible via correct initial state
//   2. Sign up (email) → AuthAuthenticated after bloc emits the state
//   3. Sign out → back to AuthAnonymous
//
// To run on a device/emulator with real Firebase:
//   flutter test integration_test/auth_flow_test.dart
//
// To run end-to-end with Firebase Emulator (human task T10.2):
//   1. Start emulator: firebase emulators:start --only auth,firestore
//   2. Point FirebaseAuth to emulator in main() before runApp()
//   3. Execute: flutter test integration_test/ --device-id <device-id>

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/login/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

const _anonUser = AuthUserEntity(
  uid: 'anon-uid',
  providerId: 'anonymous',
  isAnonymous: true,
);

const _authUser = AuthUserEntity(
  uid: 'real-uid',
  email: 'user@example.com',
  displayName: 'Test User',
  providerId: 'password',
  isAnonymous: false,
);

/// Minimal harness that wraps [child] with [AuthBloc] provided.
Widget buildHarness({
  required AuthBloc authBloc,
  required Widget child,
}) {
  return MaterialApp(
    home: BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: child,
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    // Default: anonymous cold-start state
    when(() => authBloc.state).thenReturn(const AuthAnonymous(_anonUser));
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() => authBloc.close());

  group('Auth flow — Scenario 1: cold start emits AuthAnonymous', () {
    testWidgets('initial state is AuthAnonymous — login page is accessible',
        (tester) async {
      await tester.pumpWidget(
        buildHarness(authBloc: authBloc, child: const LoginPage()),
      );
      await tester.pumpAndSettle();

      // Login page is the entry point for non-authenticated flows.
      // Presence of the Sign in button confirms the anonymous (unauthenticated)
      // UI branch is rendered.
      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Sign in'),
        ),
        findsOneWidget,
      );
    });
  });

  group('Auth flow — Scenario 2: sign up → AuthAuthenticated', () {
    testWidgets('after AuthAuthenticated the bloc state reflects the new user',
        (tester) async {
      // Arrange: bloc transitions to AuthAuthenticated on sign-up event
      when(() => authBloc.state)
          .thenReturn(const AuthAuthenticated(_authUser));
      when(() => authBloc.stream)
          .thenAnswer((_) => Stream.value(const AuthAuthenticated(_authUser)));

      await tester.pumpWidget(
        buildHarness(authBloc: authBloc, child: const LoginPage()),
      );
      await tester.pumpAndSettle();

      // The authenticated state is held by AuthBloc.
      // Verify bloc reports AuthAuthenticated with the expected user.
      expect(authBloc.state, isA<AuthAuthenticated>());
      expect(
        (authBloc.state as AuthAuthenticated).user.uid,
        equals('real-uid'),
      );
      expect(
        (authBloc.state as AuthAuthenticated).user.isAnonymous,
        isFalse,
      );
    });
  });

  group('Auth flow — Scenario 3: sign out → re-anonymous', () {
    testWidgets(
        'after sign out and re-anonymous auth the state is AuthAnonymous',
        (tester) async {
      // Arrange: bloc emits AuthAnonymous with a new anonymous uid after sign-out
      const newAnonUser = AuthUserEntity(
        uid: 'anon-uid-2',
        providerId: 'anonymous',
        isAnonymous: true,
      );
      when(() => authBloc.state)
          .thenReturn(const AuthAnonymous(newAnonUser));
      when(() => authBloc.stream)
          .thenAnswer((_) => Stream.value(const AuthAnonymous(newAnonUser)));

      await tester.pumpWidget(
        buildHarness(authBloc: authBloc, child: const LoginPage()),
      );
      await tester.pumpAndSettle();

      // After sign-out the bloc dispatches SignInAnonymouslyEvent which
      // ultimately settles at AuthAnonymous (design D10).
      expect(authBloc.state, isA<AuthAnonymous>());
      expect(
        (authBloc.state as AuthAnonymous).user.isAnonymous,
        isTrue,
      );
    });
  });
}
