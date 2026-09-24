import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/alert_banner.dart';
import '../../../../helpers/localized_app.dart';

void main() {
  Future<void> pumpBanner(
    WidgetTester tester, {
    required String message,
    AlertTone tone = AlertTone.error,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: Scaffold(body: AlertBanner(message, tone: tone)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('says what went wrong', (tester) async {
    await pumpBanner(
      tester,
      message: 'That email and password do not match an account.',
    );

    expect(
      find.text('That email and password do not match an account.'),
      findsOneWidget,
    );
  });

  testWidgets('carries an icon, so the meaning does not rest on colour alone',
      (tester) async {
    await pumpBanner(tester, message: 'Something went wrong.');

    // Somebody who cannot separate red from grey still gets the message.
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('changes its icon with its tone', (tester) async {
    await pumpBanner(
      tester,
      message: 'Your article is live.',
      tone: AlertTone.success,
    );

    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });

  testWidgets('announces itself to a screen reader', (tester) async {
    await pumpBanner(tester, message: 'Enter your email.');

    final semantics = tester.getSemantics(
      find.byType(AlertBanner),
    );

    expect(semantics.flagsCollection.isLiveRegion, isTrue);
  });

  testWidgets('shows every broken rule at once', (tester) async {
    await pumpBanner(
      tester,
      message: 'Enter your email.\nUse at least 8 characters.',
    );

    expect(
      find.text('Enter your email.\nUse at least 8 characters.'),
      findsOneWidget,
    );
  });
}
