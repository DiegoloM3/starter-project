import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_in/sign_in_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/auth_error_banner.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/fields/labeled_text_field.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const SignInParams(email: '', password: ''));
  });

  late MockSignInWithEmailUseCase signInWithEmail;
  late MockSignInWithGoogleUseCase signInWithGoogle;
  late SignInCubit cubit;

  setUp(() {
    signInWithEmail = MockSignInWithEmailUseCase();
    signInWithGoogle = MockSignInWithGoogleUseCase();
    cubit = SignInCubit(signInWithEmail, signInWithGoogle);
  });
  tearDown(() => cubit.close());

  Future<void> pumpView(WidgetTester tester) async {
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.signIn,
      routes: {
        AppRoutes.signIn: (_) => BlocProvider.value(value: cubit, child: const SignInView()),
        AppRoutes.welcome: (_) => const Text('welcome'),
        AppRoutes.signUp: (_) => const Text('sign-up'),
      },
      providers: [],
    );
    await tester.pumpAndSettle();
  }

  Finder fieldLabelled(String label) => find.descendant(
        of: find.widgetWithText(LabeledTextField, label),
        matching: find.byType(TextField),
      );

  testWidgets('submitting an empty form shows one sentence per field', (tester) async {
    await pumpView(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text(CredentialValidationError.emptyEmail.message), findsOneWidget);
    expect(find.text(CredentialValidationError.emptyPassword.message), findsOneWidget);
    verifyNever(() => signInWithEmail(any()));
  });

  testWidgets('a valid form reaches the use case with the typed credentials', (tester) async {
    when(() => signInWithEmail(any())).thenAnswer((_) async => const DataSuccess(user));
    await pumpView(tester);

    await tester.enterText(fieldLabelled('Email'), 'ada@example.com');
    await tester.enterText(fieldLabelled('Password'), 'secret123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    verify(() => signInWithEmail(
          const SignInParams(email: 'ada@example.com', password: 'secret123'),
        )).called(1);
  });

  testWidgets('a wrong password is explained under the password field', (tester) async {
    when(() => signInWithEmail(any()))
        .thenAnswer((_) async => const DataFailed(Failure.invalidCredentials()));
    await pumpView(tester);

    await tester.enterText(fieldLabelled('Email'), 'ada@example.com');
    await tester.enterText(fieldLabelled('Password'), 'wrong');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.textContaining("That password isn't right"), findsOneWidget);
    expect(find.byType(AuthErrorBanner), findsNothing);
  });

  testWidgets('any other failure shows the banner above the button', (tester) async {
    when(() => signInWithEmail(any()))
        .thenAnswer((_) async => const DataFailed(Failure.network()));
    await pumpView(tester);

    await tester.enterText(fieldLabelled('Email'), 'ada@example.com');
    await tester.enterText(fieldLabelled('Password'), 'secret123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthErrorBanner), findsOneWidget);
    expect(find.textContaining('internet connection'), findsOneWidget);
  });

  testWidgets('Show / Hide toggles whether the password is obscured', (tester) async {
    await pumpView(tester);

    expect(tester.widget<TextField>(fieldLabelled('Password')).obscureText, isTrue);
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(fieldLabelled('Password')).obscureText, isFalse);
    expect(find.text('Hide'), findsOneWidget);
  });

  testWidgets('Continue with Google calls its use case', (tester) async {
    when(() => signInWithGoogle(any())).thenAnswer((_) async => const DataSuccess(user));
    await pumpView(tester);

    await tester.ensureVisible(find.text('Continue with Google'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    verify(() => signInWithGoogle(any())).called(1);
  });

  testWidgets('Back returns to Welcome and the footer opens Sign up', (tester) async {
    final router = await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.signIn,
      routes: {
        AppRoutes.signIn: (_) => BlocProvider.value(value: cubit, child: const SignInView()),
        AppRoutes.welcome: (_) => const Text('welcome'),
        AppRoutes.signUp: (_) => const Text('sign-up'),
      },
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
    expect(locationOf(router), AppRoutes.welcome);

    router.go(AppRoutes.signIn);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create an account'));
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(locationOf(router), AppRoutes.signUp);
  });

  testWidgets('SignInScreen builds its cubit from the service locator', (tester) async {
    sl.registerFactory<SignInCubit>(() => SignInCubit(signInWithEmail, signInWithGoogle));
    addTearDown(() => sl.unregister<SignInCubit>());

    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.signIn,
      routes: {AppRoutes.signIn: (_) => const SignInScreen()},
    );
    await tester.pumpAndSettle();

    expect(find.text('WELCOME BACK'), findsOneWidget);
  });
}
