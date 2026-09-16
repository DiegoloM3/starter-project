import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_up/sign_up_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/auth_error_banner.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/sign_up/password_strength_meter.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/fields/labeled_text_field.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const SignUpParams(displayName: '', email: '', password: ''));
  });

  late MockSignUpWithEmailUseCase signUpWithEmail;
  late MockSignInWithGoogleUseCase signInWithGoogle;
  late SignUpCubit cubit;

  setUp(() {
    signUpWithEmail = MockSignUpWithEmailUseCase();
    signInWithGoogle = MockSignInWithGoogleUseCase();
    cubit = SignUpCubit(signUpWithEmail, signInWithGoogle);
  });
  tearDown(() => cubit.close());

  Future<void> pumpView(WidgetTester tester) async {
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.signUp,
      routes: {
        AppRoutes.signUp: (_) => BlocProvider.value(value: cubit, child: const SignUpView()),
        AppRoutes.welcome: (_) => const Text('welcome'),
        AppRoutes.signIn: (_) => const Text('sign-in'),
      },
    );
    await tester.pumpAndSettle();
  }

  Finder fieldLabelled(String label) => find.descendant(
        of: find.widgetWithText(LabeledTextField, label),
        matching: find.byType(TextField),
      );

  Future<void> fillValidForm(WidgetTester tester) async {
    await tester.enterText(fieldLabelled('Display name'), 'Ada Lovelace');
    await tester.enterText(fieldLabelled('Email'), 'ada@example.com');
    await tester.enterText(fieldLabelled('Password'), 'Harbour-lamp-42');
    await tester.pumpAndSettle();
  }

  testWidgets('the strength meter appears once a password is typed', (tester) async {
    await pumpView(tester);
    expect(find.byType(PasswordStrengthMeter), findsNothing);

    await tester.enterText(fieldLabelled('Password'), 'abc');
    await tester.pumpAndSettle();
    expect(find.textContaining(PasswordStrength.weak.title.toUpperCase()), findsOneWidget);

    await tester.enterText(fieldLabelled('Password'), 'Harbour-lamp-42');
    await tester.pumpAndSettle();
    expect(find.textContaining(PasswordStrength.strong.title.toUpperCase()), findsOneWidget);
  });

  testWidgets('a weak password never blocks the form, a short one does', (tester) async {
    when(() => signUpWithEmail(any())).thenAnswer((_) async => const DataSuccess(user));
    await pumpView(tester);
    await tester.enterText(fieldLabelled('Display name'), 'Ada');
    await tester.enterText(fieldLabelled('Email'), 'ada@example.com');
    await tester.enterText(fieldLabelled('Password'), 'abc');

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Create account'));
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();
    expect(find.text(CredentialValidationError.shortPassword.message), findsOneWidget);
    verifyNever(() => signUpWithEmail(any()));

    await tester.enterText(fieldLabelled('Password'), 'abcdefgh');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();
    verify(() => signUpWithEmail(any())).called(1);
  });

  testWidgets('a complete form reaches the use case with every field', (tester) async {
    when(() => signUpWithEmail(any())).thenAnswer((_) async => const DataSuccess(user));
    await pumpView(tester);
    await fillValidForm(tester);

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Create account'));
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    verify(() => signUpWithEmail(const SignUpParams(
          displayName: 'Ada Lovelace',
          email: 'ada@example.com',
          password: 'Harbour-lamp-42',
        ))).called(1);
  });

  testWidgets('an email already in use shows the banner', (tester) async {
    when(() => signUpWithEmail(any()))
        .thenAnswer((_) async => const DataFailed(Failure.emailAlreadyInUse()));
    await pumpView(tester);
    await fillValidForm(tester);

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Create account'));
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthErrorBanner), findsOneWidget);
    expect(find.textContaining('already an account'), findsOneWidget);
  });

  testWidgets('Google and the footer link work from sign up too', (tester) async {
    when(() => signInWithGoogle(any())).thenAnswer((_) async => const DataSuccess(user));
    final router = await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.signUp,
      routes: {
        AppRoutes.signUp: (_) => BlocProvider.value(value: cubit, child: const SignUpView()),
        AppRoutes.welcome: (_) => const Text('welcome'),
        AppRoutes.signIn: (_) => const Text('sign-in'),
      },
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue with Google'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    verify(() => signInWithGoogle(any())).called(1);

    await tester.ensureVisible(find.widgetWithText(TextButton, 'Sign in'));
    await tester.tap(find.widgetWithText(TextButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(locationOf(router), AppRoutes.signIn);
  });

  testWidgets('SignUpScreen builds its cubit from the service locator', (tester) async {
    sl.registerFactory<SignUpCubit>(() => SignUpCubit(signUpWithEmail, signInWithGoogle));
    addTearDown(() => sl.unregister<SignUpCubit>());

    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.signUp,
      routes: {AppRoutes.signUp: (_) => const SignUpScreen()},
    );
    await tester.pumpAndSettle();

    expect(find.text('CREATE YOUR ACCOUNT'), findsOneWidget);
  });
}
