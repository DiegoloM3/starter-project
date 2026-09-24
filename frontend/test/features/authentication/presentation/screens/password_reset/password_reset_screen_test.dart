import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/alert_banner.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/request_password_reset.dart';
import 'package:news_app_clean_architecture/features/authentication/presentation/bloc/password_reset/password_reset_cubit.dart';
import 'package:news_app_clean_architecture/features/authentication/presentation/screens/password_reset/password_reset_screen.dart';

import '../../../../../helpers/fake_auth_repository.dart';
import '../../../../../helpers/localized_app.dart';

void main() {
  late FakeAuthRepository repository;
  late PasswordResetCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
  });

  tearDown(() => cubit.close());

  Future<void> pumpScreen(WidgetTester tester) async {
    cubit = PasswordResetCubit(RequestPasswordResetUseCase(repository));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: BlocProvider<PasswordResetCubit>.value(
          value: cubit,
          child: const PasswordResetScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> request(WidgetTester tester, String email) async {
    await tester.enterText(find.byType(TextField).first, email);
    await tester.tap(find.widgetWithText(FilledButton, 'Send reset link'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('asks for the address first', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Reset password'), findsOneWidget);
    expect(
        find.widgetWithText(FilledButton, 'Send reset link'), findsOneWidget);
  });

  testWidgets('a malformed address is reported as a banner', (tester) async {
    await pumpScreen(tester);

    await request(tester, 'not-an-email');

    expect(find.byType(AlertBanner), findsOneWidget);
    expect(repository.passwordResetCallCount, 0);
  });

  testWidgets('confirms the request without confirming the account exists',
      (tester) async {
    await pumpScreen(tester);

    await request(tester, 'alex@example.com');

    expect(find.text('Reset requested'), findsOneWidget);
    expect(find.textContaining('If that email has an account'), findsOneWidget);
    // Naming the address back would confirm it is registered.
    expect(find.textContaining('alex@example.com'), findsNothing);
  });

  testWidgets('warns that the email often lands in spam', (tester) async {
    await pumpScreen(tester);

    await request(tester, 'alex@example.com');

    expect(find.textContaining('spam or promotions'), findsOneWidget);
    expect(
        find.widgetWithText(FilledButton, 'Back to sign in'), findsOneWidget);
  });
}
