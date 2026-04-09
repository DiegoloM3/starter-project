import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/utils/format_published_at.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/widgets/community_article_detail_title_and_date.dart';

// Pins spec 012 scenario 11: the title is always shown; the date row
// is only present when publishedAt is non-null and non-empty.

Widget _pump(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('CommunityArticleDetailTitleAndDate', () {
    testWidgets(
      'shows title and formatted date when publishedAt is provided',
      (tester) async {
        const iso = '2026-04-08T12:00:00Z';
        await tester.pumpWidget(_pump(const CommunityArticleDetailTitleAndDate(
          title: 'The Title',
          publishedAt: iso,
        )));

        expect(find.text('The Title'), findsOneWidget);
        // Date is formatted through the shared helper — we assert on the
        // exact output of that helper so the test stays timezone-safe.
        expect(find.text(formatPublishedAt(iso)), findsOneWidget);
      },
    );

    testWidgets(
      'omits the date row when publishedAt is null',
      (tester) async {
        await tester.pumpWidget(_pump(const CommunityArticleDetailTitleAndDate(
          title: 'Only Title',
          publishedAt: null,
        )));

        expect(find.text('Only Title'), findsOneWidget);
        // Only one Text widget (the title); no date row underneath.
        expect(find.byType(Text), findsOneWidget);
      },
    );

    testWidgets(
      'omits the date row when publishedAt is an empty string',
      (tester) async {
        await tester.pumpWidget(_pump(const CommunityArticleDetailTitleAndDate(
          title: 'Only Title',
          publishedAt: '',
        )));

        expect(find.byType(Text), findsOneWidget);
      },
    );
  });
}
