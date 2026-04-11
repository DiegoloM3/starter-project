import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/headers/expandable_search_header.dart';

import '../../../../../helpers/test_wrapper.dart';

void main() {
  group('ExpandableSearchHeader', () {
    Widget buildHeader({ValueChanged<String>? onSearchChanged}) {
      return testableWidget(
        ExpandableSearchHeader(
          title: 'Daily News',
          searchHint: 'Search news...',
          cancelLabel: 'Cancel',
          searchButtonLabel: 'Search',
          onSearchChanged: onSearchChanged ?? (_) {},
          actions: const Icon(Icons.person),
        ),
      );
    }

    testWidgets('shows title in default state', (tester) async {
      await tester.pumpWidget(buildHeader());

      expect(find.text('Daily News'), findsOneWidget);
    });

    testWidgets('shows actions widget in default state', (tester) async {
      await tester.pumpWidget(buildHeader());

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows search icon button in default state', (tester) async {
      await tester.pumpWidget(buildHeader());

      expect(find.bySemanticsLabel('Search'), findsOneWidget);
    });

    testWidgets('tapping search icon shows text field', (tester) async {
      await tester.pumpWidget(buildHeader());

      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search news...'), findsOneWidget);
    });

    testWidgets('shows cancel label in search mode', (tester) async {
      await tester.pumpWidget(buildHeader());

      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('cancel returns to default header', (tester) async {
      await tester.pumpWidget(buildHeader());

      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Daily News'), findsOneWidget);
      expect(find.bySemanticsLabel('Search'), findsOneWidget);
    });

    testWidgets('cancel calls onSearchChanged with empty string',
        (tester) async {
      String? lastQuery;
      await tester.pumpWidget(
        buildHeader(onSearchChanged: (q) => lastQuery = q),
      );

      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(lastQuery, '');
    });

    testWidgets('typing triggers onSearchChanged after debounce',
        (tester) async {
      final completer = Completer<String>();
      await tester.pumpWidget(
        buildHeader(onSearchChanged: (q) {
          if (!completer.isCompleted) completer.complete(q);
        }),
      );

      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump(const Duration(milliseconds: 350));

      expect(completer.isCompleted, isTrue);
      expect(await completer.future, 'flutter');
    });

    testWidgets('search button has semantic label', (tester) async {
      await tester.pumpWidget(buildHeader());

      expect(
        find.bySemanticsLabel('Search'),
        findsOneWidget,
      );
    });

    testWidgets('accepts custom titleStyle', (tester) async {
      const customStyle = TextStyle(fontSize: 32, color: Colors.red);
      await tester.pumpWidget(
        testableWidget(
          ExpandableSearchHeader(
            title: 'Custom Title',
            titleStyle: customStyle,
            searchHint: 'Search...',
            cancelLabel: 'Cancel',
            searchButtonLabel: 'Search',
            onSearchChanged: (_) {},
            actions: const SizedBox.shrink(),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Custom Title'));
      expect(text.style?.fontSize, 32);
      expect(text.style?.color, Colors.red);
    });
  });
}
