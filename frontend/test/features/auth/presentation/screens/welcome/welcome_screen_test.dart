import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/welcome/welcome_screen.dart';

void main() {
  Future<void> openWelcome(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme(),
      home: const WelcomeScreen(),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(body: Text('Opened ${settings.name}')),
      ),
    ));
  }

  testWidgets('invites to read the news and publish your own', (tester) async {
    await openWelcome(tester);

    expect(find.text('Read the news.\nPublish your own.'), findsOneWidget);
  });

  testWidgets('opens the registration form', (tester) async {
    await openWelcome(tester);

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Opened /Register'), findsOneWidget);
  });

  testWidgets('opens the log-in form', (tester) async {
    await openWelcome(tester);

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Opened /SignIn'), findsOneWidget);
  });
}
