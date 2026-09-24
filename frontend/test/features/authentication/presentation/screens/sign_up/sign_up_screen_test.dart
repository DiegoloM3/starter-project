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
import 'package:news_app_clean_architecture/features/authentication/presentation/screens/sign_up/sign_up_screen.dart';

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
          child: const SignUpScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  /// The fields are in the order the form presents them: name, email,
  /// password, repeat password.
  Future<void> submit(
    WidgetTester tester, {
    String name = 'Alex Rivera',
    String email = 'alex@example.com',
    String password = 'correct horse',
    String? repeatPassword,
  }) async {
    final fields = find.byType(TextField);

    await tester.enterText(fields.at(0), name);
    await tester.enterText(fields.at(1), email);
    await tester.enterText(fields.at(2), password);
    await tester.enterText(fields.at(3), repeatPassword ?? password);
    // The form scrolls (see CenteredForm), and on the test's short
    // viewport the button can start below the fold.
    final submitButton = find.widgetWithText(ElevatedButton, 'Create account');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('asks for a name, an email and the password twice',
      (tester) async {
    await pumpScreen(tester);

    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.text('Name readers will see (optional)'), findsOneWidget);
    expect(find.text('Repeat password'), findsOneWidget);
  });

  /// Said before they type rather than after they fail.
  testWidgets('states the password rule up front', (tester) async {
    await pumpScreen(tester);

    expect(find.text('At least 8 characters'), findsOneWidget);
  });

  testWidgets('shows no alert before anything has gone wrong', (tester) async {
    await pumpScreen(tester);

    expect(find.byType(AlertBanner), findsNothing);
  });

  testWidgets('creates the account with what was typed', (tester) async {
    await pumpScreen(tester);

    await submit(tester);

    expect(repository.signUpCallCount, 1);
    expect(repository.lastEmail, 'alex@example.com');
    expect(repository.lastDisplayName, 'Alex Rivera');
  });

  /// The name is optional, so leaving it blank must not stop the sign up.
  testWidgets('an account can be created without a name', (tester) async {
    await pumpScreen(tester);

    await submit(tester, name: '');

    expect(repository.signUpCallCount, 1);
    expect(repository.lastDisplayName, '');
  });

  group('caught before the network', () {
    testWidgets('two different passwords', (tester) async {
      await pumpScreen(tester);

      await submit(
        tester,
        password: 'correct horse',
        repeatPassword: 'correct hoarse',
      );

      expect(find.text('The two passwords are different.'), findsOneWidget);
      expect(repository.signUpCallCount, 0);
    });

    testWidgets('a password shorter than the rule', (tester) async {
      await pumpScreen(tester);

      await submit(tester, password: 'short');

      expect(find.text('Use at least 8 characters.'), findsOneWidget);
      expect(repository.signUpCallCount, 0);
    });

    testWidgets('a malformed email', (tester) async {
      await pumpScreen(tester);

      await submit(tester, email: 'not-an-email');

      expect(
        find.text('That does not look like an email address.'),
        findsOneWidget,
      );
      expect(repository.signUpCallCount, 0);
    });
  });

  testWidgets('an address that is already registered says where to go next',
      (tester) async {
    repository.signUpResult = const DataFailed(
      EmailAlreadyRegisteredException(),
    );
    await pumpScreen(tester);

    await submit(tester);

    expect(find.byType(AlertBanner), findsOneWidget);
    expect(
      find.text('That email already has an account. Sign in instead.'),
      findsOneWidget,
    );
  });

  testWidgets('survives a short screen with the system font at 200%',
      (tester) async {
    // The reader who has turned their text size up has to be able to make an
    // account too. Centred content that cannot scroll would overflow here.
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
            child: const SignUpScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
