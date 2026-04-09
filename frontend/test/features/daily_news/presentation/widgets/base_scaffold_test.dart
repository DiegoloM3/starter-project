import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/base_scaffold.dart';

void main() {
  group('BaseScaffold', () {
    testWidgets('renders body correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BaseScaffold(
            body: Center(key: Key('test_body'), child: Text('Body Text')),
          ),
        ),
      );

      expect(find.byKey(const Key('test_body')), findsOneWidget);
      expect(find.text('Body Text'), findsOneWidget);
    });

    testWidgets('renders all optional components correctly',
        (WidgetTester tester) async {
      final actions = [
        IconButton(
          key: const Key('action_button'),
          icon: const Icon(Icons.settings),
          onPressed: () {},
        ),
      ];

      const leading = Icon(Icons.menu, key: Key('leading_icon'));
      final fab = FloatingActionButton(
        key: const Key('fab'),
        onPressed: () {},
        child: const Icon(Icons.add),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BaseScaffold(
            text: 'Test Title',
            leading: leading,
            actions: actions,
            floatingActionButton: fab,
            body: const Text('Body Text'),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byKey(const Key('leading_icon')), findsOneWidget);
      expect(find.byKey(const Key('action_button')), findsOneWidget);
      expect(find.byKey(const Key('fab')), findsOneWidget);
    });
  });

  group('BaseScaffold.withBackNavigation', () {
    testWidgets('renders body and back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BaseScaffold.withBackNavigation(
            text: 'Test Title',
            body: const Text('Body Text'),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Body Text'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('calls onTapGoBack when back button is tapped',
        (WidgetTester tester) async {
      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BaseScaffold.withBackNavigation(
            body: const Text('Body Text'),
            onTapGoBack: () {
              backTapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(backTapped, isTrue);
    });

    testWidgets(
        'pops Navigator when back button is tapped and no onTapGoBack provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BaseScaffold.withBackNavigation(
                        body: const Text('Second Page'),
                      ),
                    ),
                  );
                },
                child: const Text('Push'),
              );
            },
          ),
        ),
      );

      expect(find.text('Push'), findsOneWidget);
      expect(find.text('Second Page'), findsNothing);

      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('Push'), findsOneWidget);
      expect(find.text('Second Page'), findsNothing);
    });
  });
}
