import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/cards/card_news.dart';

import '../../../../../helpers/test_wrapper.dart';

void main() {
  group('CardNews', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const CardNews(title: 'Breaking News', date: '2026-04-11'),
        ),
      );

      expect(find.text('Breaking News'), findsOneWidget);
    });

    testWidgets('renders date', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const CardNews(title: 'Title', date: '2026-04-11'),
        ),
      );

      expect(find.text('2026-04-11'), findsOneWidget);
    });

    testWidgets('renders description when provided', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const CardNews(
            title: 'Title',
            date: '2026-04-11',
            description: 'A long description here',
          ),
        ),
      );

      expect(find.text('A long description here'), findsOneWidget);
    });

    testWidgets('does not render description when null', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const CardNews(title: 'Title', date: '2026-04-11'),
        ),
      );

      expect(find.byType(Text), findsNWidgets(2));
    });

    testWidgets('shows outline bookmark icon when not bookmarked',
        (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const CardNews(
            title: 'Title',
            date: '2026-04-11',
            isBookmarked: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.bookmark_outline), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsNothing);
    });

    testWidgets('shows filled bookmark icon when bookmarked', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const CardNews(
            title: 'Title',
            date: '2026-04-11',
            isBookmarked: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('bookmark icon uses coral color when bookmarked',
        (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const CardNews(
            title: 'Title',
            date: '2026-04-11',
            isBookmarked: true,
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.bookmark));
      expect(icon.color, AppColors.coral);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        testableWidget(
          CardNews(
            title: 'Tappable',
            date: '2026-04-11',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Tappable'));
      expect(tapped, isTrue);
    });

    testWidgets('calls onBookmarkTap when bookmark is tapped', (tester) async {
      var bookmarkTapped = false;
      await tester.pumpWidget(
        testableWidget(
          CardNews(
            title: 'Title',
            date: '2026-04-11',
            onBookmarkTap: () => bookmarkTapped = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.bookmark_outline));
      expect(bookmarkTapped, isTrue);
    });

    testWidgets('renders section badge when provided', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const CardNews(
            title: 'Title',
            date: '2026-04-11',
            sectionBadge: Chip(label: Text('Sports')),
          ),
        ),
      );

      expect(find.text('Sports'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('does not render section badge when null', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const CardNews(title: 'Title', date: '2026-04-11'),
        ),
      );

      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('shows trailing widget instead of bookmark when provided',
        (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const CardNews(
            title: 'Title',
            date: '2026-04-11',
            trailing: Icon(Icons.delete),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_outline), findsNothing);
    });

    testWidgets('shows placeholder icon when imageUrl is null',
        (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const CardNews(title: 'Title', date: '2026-04-11'),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });
  });
}
