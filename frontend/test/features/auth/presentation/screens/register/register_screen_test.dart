import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_error.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/registration_draft.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/register.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/register/register_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/register/register_screen.dart';

/// Creates every account except the ones whose email is already taken, as Firebase Authentication would.
class FakeAuthRepository implements AuthRepository {
  static const String takenEmail = 'taken@example.com';

  RegistrationDraftEntity? registeredDraft;

  @override
  Future<DataState<UserEntity>> register(RegistrationDraftEntity draft) async {
    if (draft.email == takenEmail) return const DataFailed(AuthException(AuthError.emailAlreadyInUse));
    registeredDraft = draft;
    return DataSuccess(UserEntity(id: 'newUid', name: draft.name, email: draft.email));
  }

  @override
  Stream<UserEntity?> watchSession() => const Stream.empty();

  @override
  Future<DataState<UserEntity>> signIn(String email, String password) => throw UnimplementedError();

  @override
  Future<DataState<void>> signOut() => throw UnimplementedError();
}

/// User journey "create an account", with the real cubit and use case and a fake repository.
void main() {
  late FakeAuthRepository repository;

  Future<void> openRegisterScreen(WidgetTester tester) async {
    repository = FakeAuthRepository();
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
                  create: (_) => RegisterCubit(RegisterUseCase(repository)),
                  child: const RegisterScreen(),
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

  /// Fields are found by their hint, shown inside them while they are empty.
  Future<void> fillIn(WidgetTester tester, String hint, String text) async {
    final field = find.widgetWithText(TextField, hint);
    await tester.scrollUntilVisible(field, 100, scrollable: find.byType(Scrollable).first);
    await tester.enterText(field, text);
  }

  Future<void> fillInForm(WidgetTester tester, {String email = 'jane@example.com', String? confirmation}) async {
    await fillIn(tester, 'Jane Doe', 'Jane Doe');
    await fillIn(tester, 'you@example.com', email);
    await fillIn(tester, 'Create a password', 'a-long-password');
    await fillIn(tester, 'Repeat your password', confirmation ?? 'a-long-password');
  }

  Future<void> tapCreateAccount(WidgetTester tester) async {
    final button = find.widgetWithText(FilledButton, 'Create account');
    await tester.scrollUntilVisible(button, 100, scrollable: find.byType(Scrollable).first);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('explains what the name and the password are for', (tester) async {
    await openRegisterScreen(tester);

    expect(find.text('Shown as the author of your articles.'), findsOneWidget);
    expect(find.text('At least 8 characters.'), findsOneWidget);
  });

  testWidgets('shows what is missing when creating an account with an empty form', (tester) async {
    await openRegisterScreen(tester);

    await tapCreateAccount(tester);

    expect(find.text('This field is required'), findsNWidgets(4));
    expect(repository.registeredDraft, isNull);
  });

  testWidgets('asks to repeat the same password', (tester) async {
    await openRegisterScreen(tester);

    await fillInForm(tester, confirmation: 'another-password');
    await tapCreateAccount(tester);

    expect(find.text('The passwords do not match'), findsOneWidget);
    expect(repository.registeredDraft, isNull);
  });

  testWidgets('both password fields have their own eye', (tester) async {
    await openRegisterScreen(tester);
    bool isHidden(String hint) => tester.widget<TextField>(find.widgetWithText(TextField, hint)).obscureText;

    await tester.tap(find.byTooltip('Show password').last);
    await tester.pump();

    expect(isHidden('Create a password'), isTrue);
    expect(isHidden('Repeat your password'), isFalse);
  });

  testWidgets('tells the journalist when the email already has an account', (tester) async {
    await openRegisterScreen(tester);

    await fillInForm(tester, email: FakeAuthRepository.takenEmail);
    await tapCreateAccount(tester);

    expect(find.text('There is already an account with this email.'), findsOneWidget);
    expect(find.byType(RegisterScreen), findsOneWidget);
    // The toast closes by itself after a few seconds.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('creates the account and closes', (tester) async {
    await openRegisterScreen(tester);

    await fillInForm(tester);
    await tapCreateAccount(tester);

    expect(repository.registeredDraft?.name, 'Jane Doe');
    expect(find.byType(RegisterScreen), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });
}
