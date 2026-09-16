import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/welcome_screen.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/brand_mark.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the logo, wordmark, value line and both ways in', (tester) async {
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.welcome,
      routes: {AppRoutes.welcome: (_) => const WelcomeScreen()},
    );

    expect(find.byType(BrandMark), findsOneWidget);
    expect(find.text('HEADLINE\nNEWS'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Create account'), findsOneWidget);
  });

  testWidgets('Sign in and Create account open their forms', (tester) async {
    final router = await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.welcome,
      routes: {
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.signIn: (_) => const Text('sign-in form'),
        AppRoutes.signUp: (_) => const Text('sign-up form'),
      },
    );

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(locationOf(router), AppRoutes.signIn);
    expect(find.text('sign-in form'), findsOneWidget);

    router.go(AppRoutes.welcome);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(locationOf(router), AppRoutes.signUp);
  });
}
