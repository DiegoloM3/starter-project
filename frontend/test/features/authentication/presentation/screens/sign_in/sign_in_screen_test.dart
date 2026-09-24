import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/alert_banner.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/entities/auth_failures.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/sign_in.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/sign_up.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/update_display_name.dart';
import 'package:news_app_clean_architecture/features/authentication/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/authentication/presentation/screens/sign_in/sign_in_screen.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/app_brand.dart';

import '../../../../../helpers/fake_auth_repository.dart';
import '../../../../../helpers/localized_app.dart';

void main() {
  late FakeAuthRepository repository;
  late SessionCubit session;

  setUp(() {
    repository = FakeAuthRepository();
  });

  tearDown(() => session.close());

  // Built here, not in setUp: a cubit created in setUp runs against the real
  // clock and never advances under `tester.pump()`.
  Future<void> pumpScreen(WidgetTester tester) async {
    session = SessionCubit(
      GetCurrentUserUseCase(repository),
      SignUpUseCase(repository),
      SignInUseCase(repository),
      SignOutUseCase(repository),
      UpdateDisplayNameUseCase(repository),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: BlocProvider<SessionCubit>.value(
          value: session,
          child: const SignInScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> submit(
      WidgetTester tester, String email, String password) async {
    await tester.enterText(find.byType(TextField).first, email);
    await tester.enterText(find.byType(TextField).last, password);
    // The form scrolls (see CenteredForm), and on the test's short
    // viewport the button can start below the fold.
    final submitButton = find.widgetWithText(ElevatedButton, 'Sign in');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('shows no alert before anything has gone wrong', (tester) async {
    await pumpScreen(tester);

    expect(find.byType(AlertBanner), findsNothing);
  });

  testWidgets('rejected credentials come back as a banner, not loose text',
      (tester) async {
    repository.signInResult = const DataFailed(InvalidCredentialsException());
    await pumpScreen(tester);

    await submit(tester, 'invalid_user@mail.com', 'wrongpass123');

    expect(find.byType(AlertBanner), findsOneWidget);
    expect(
      find.text('That email and password do not match an account.'),
      findsOneWidget,
    );
  });

  testWidgets('the message never reveals which half was wrong', (tester) async {
    repository.signInResult = const DataFailed(InvalidCredentialsException());
    await pumpScreen(tester);

    await submit(tester, 'nobody@mail.com', 'whatever123');

    // Telling "no such account" apart from "wrong password" would let anyone
    // find out who is registered here.
    expect(find.textContaining('password is'), findsNothing);
    expect(find.textContaining('No account'), findsNothing);
  });

  testWidgets('survives a short screen with the system font at 200%',
      (tester) async {
    // The design has to hold up for somebody who has turned their text size
    // up, which is exactly the reader this app is meant to work for. Centred
    // content that cannot scroll would overflow here.
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    session = SessionCubit(
      GetCurrentUserUseCase(repository),
      SignUpUseCase(repository),
      SignInUseCase(repository),
      SignOutUseCase(repository),
      UpdateDisplayNameUseCase(repository),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: BlocProvider<SessionCubit>.value(
            value: session,
            child: const SignInScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('a malformed email is caught before the network', (tester) async {
    await pumpScreen(tester);

    await submit(tester, 'not-an-email', 'whatever123');

    expect(find.byType(AlertBanner), findsOneWidget);
    expect(
      find.text('That does not look like an email address.'),
      findsOneWidget,
    );
    expect(repository.signInCallCount, 0);
  });

  testWidgets('says what the person is signing in to', (tester) async {
    await pumpScreen(tester);

    // The screen used to open on a bare "Sign in" bar over two fields, which
    // is a form rather than a front door: nothing on it named the app.
    expect(find.byType(AppBrandHeader), findsOneWidget);
    expect(find.text('Byline'), findsOneWidget);
  });

  /// The session is one object for the whole app, so a failure raised on
  /// another screen was still sitting here when the person arrived. Somebody
  /// who mistyped a password on the sign-up screen met the same red message
  /// again on sign in, about something they had not done here.
  testWidgets('never shows a failure raised on another screen', (tester) async {
    session = SessionCubit(
      GetCurrentUserUseCase(repository),
      SignUpUseCase(repository),
      SignInUseCase(repository),
      SignOutUseCase(repository),
      UpdateDisplayNameUseCase(repository),
    );

    repository.signUpResult =
        const DataFailed(EmailAlreadyRegisteredException());
    await session.signUp(
      email: 'alex@example.com',
      password: 'correct horse',
      confirmPassword: 'correct horse',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: BlocProvider<SessionCubit>.value(
          value: session,
          child: const SignInScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AlertBanner), findsNothing);
    expect(find.textContaining('already has an account'), findsNothing);
  });
}
