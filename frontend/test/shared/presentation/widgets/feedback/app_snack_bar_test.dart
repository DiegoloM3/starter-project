import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/app_snack_bar.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the message with an optional action', (tester) async {
    var undone = false;
    await pumpApp(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAppSnackBar(
              context,
              'Removed from Saved',
              actionLabel: 'Undo',
              onAction: () => undone = true,
            ),
            child: const Text('remove'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('remove'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(find.text('Removed from Saved'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(undone, isTrue);
  });

  testWidgets('a message with an action still leaves on time under accessible navigation', (tester) async {
    await pumpApp(
      tester,
      MediaQuery(
        data: const MediaQueryData(accessibleNavigation: true),
        child: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAppSnackBar(context, 'Removed from Saved', actionLabel: 'Undo'),
              child: const Text('remove'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('remove'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));
    expect(find.text('Removed from Saved'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Removed from Saved'), findsNothing);
  });
}
