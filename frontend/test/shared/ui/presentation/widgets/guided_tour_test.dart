import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/guided_tour.dart';
import '../../../../helpers/localized_app.dart';

void main() {
  final firstKey = GlobalKey();
  final secondKey = GlobalKey();

  List<GuidedTourStep> steps() => [
        GuidedTourStep(
          targetKey: firstKey,
          title: 'Start with a cover',
          body: 'Pick a picture from your phone.',
        ),
        GuidedTourStep(
          targetKey: secondKey,
          title: 'Give it a title',
          body: 'One line that says what it is about.',
        ),
      ];

  /// A screen with two things a tour can point at.
  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                Container(key: firstKey, height: 80, color: Colors.grey),
                const SizedBox(height: 40),
                Container(key: secondKey, height: 80, color: Colors.grey),
                ElevatedButton(
                  onPressed: () => GuidedTour.show(context, steps()),
                  child: const Text('Help'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openTour(WidgetTester tester) async {
    await pumpHost(tester);
    await tester.tap(find.text('Help'));
    await tester.pumpAndSettle();
  }

  testWidgets('opens on the first step and says where it is', (tester) async {
    await openTour(tester);

    expect(find.text('Start with a cover'), findsOneWidget);
    expect(find.text('Step 1 of 2'), findsOneWidget);
  });

  testWidgets('walks forward and back through the steps', (tester) async {
    await openTour(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Give it a title'), findsOneWidget);
    expect(find.text('Step 2 of 2'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Back'));
    await tester.pumpAndSettle();

    expect(find.text('Start with a cover'), findsOneWidget);
  });

  testWidgets('offers no way back on the first step', (tester) async {
    await openTour(tester);

    expect(find.widgetWithText(TextButton, 'Back'), findsNothing);
  });

  testWidgets('the last step closes rather than promising more',
      (tester) async {
    await openTour(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Got it'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Got it'));
    await tester.pumpAndSettle();

    expect(find.text('Give it a title'), findsNothing);
    expect(find.text('Help'), findsOneWidget);
  });

  testWidgets('can be left at any point', (tester) async {
    await openTour(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Start with a cover'), findsNothing);
  });

  testWidgets('never appears on its own', (tester) async {
    await pumpHost(tester);

    // A tour that starts itself is read once and resented every time after.
    expect(find.text('Start with a cover'), findsNothing);
  });

  testWidgets('the card keeps clear of what it is explaining', (tester) async {
    await openTour(tester);

    final target = tester.getRect(find.byKey(firstKey));
    final card = tester.getRect(find.text('Start with a cover'));

    // The spotlight is useless if the explanation sits on top of it.
    expect(card.top, greaterThan(target.bottom));
  });
}
