import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_error.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/registration_draft.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_in/sign_in_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/sign_in/sign_in_screen.dart';

/// Knows a single account, as Firebase Authentication would.
class FakeAuthRepository implements AuthRepository {
  static const UserEntity jane = UserEntity(id: 'janeDoeUid', name: 'Jane Doe', email: 'jane@example.com');
  static const String janePassword = 'a-long-password';

  @override
  Future<DataState<UserEntity>> signIn(String email, String password) async {
    if (email == jane.email && password == janePassword) return const DataSuccess(jane);
    return const DataFailed(AuthException(AuthError.wrongEmailOrPassword));
  }

  @override
  Stream<UserEntity?> watchSession() => const Stream.empty();

  @override
  Future<DataState<UserEntity>> register(RegistrationDraftEntity draft) => throw UnimplementedError();

  @override
  Future<DataState<void>> signOut() => throw UnimplementedError();
}

/// User journey "log in", with the real cubit and use case and a fake repository.
void main() {
  Future<void> openSignInScreen(WidgetTester tester) async {
    // Screen of the Pixel 8 used as Android emulator (412 x 914 logical pixels).
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => SignInCubit(SignInUseCase(FakeAuthRepository())),
                  child: const SignInScreen(),
                ),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> fillIn(WidgetTester tester, {required String email, required String password}) async {
    await tester.enterText(find.widgetWithText(TextField, 'you@example.com'), email);
    await tester.enterText(find.widgetWithText(TextField, 'Your password'), password);
  }

  Future<void> tapLogIn(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows what is missing when logging in with an empty form', (tester) async {
    await openSignInScreen(tester);
    expect(find.text('This field is required'), findsNothing);

    await tapLogIn(tester);

    expect(find.text('This field is required'), findsNWidgets(2));
    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('asks for a valid email', (tester) async {
    await openSignInScreen(tester);

    await fillIn(tester, email: 'jane@', password: FakeAuthRepository.janePassword);
    await tapLogIn(tester);

    expect(find.text('Enter a valid email'), findsOneWidget);
  });

  testWidgets('tells the journalist when the password is wrong and stays open', (tester) async {
    await openSignInScreen(tester);

    await fillIn(tester, email: FakeAuthRepository.jane.email, password: 'a-wrong-password');
    await tapLogIn(tester);

    expect(find.text('The email or password is incorrect.'), findsOneWidget);
    expect(find.byType(SignInScreen), findsOneWidget);
    // The toast closes by itself after a few seconds.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('hides the password until the eye is tapped', (tester) async {
    await openSignInScreen(tester);
    TextField passwordField() => tester.widget<TextField>(find.widgetWithText(TextField, 'Your password'));
    expect(passwordField().obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(passwordField().obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('logs in with the right credentials and closes', (tester) async {
    await openSignInScreen(tester);

    await fillIn(tester, email: FakeAuthRepository.jane.email, password: FakeAuthRepository.janePassword);
    await tapLogIn(tester);

    expect(find.byType(SignInScreen), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });
}
