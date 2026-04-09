import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/widgets/community_article_detail_body.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/widgets/community_article_detail_title_and_date.dart';

// Pins spec 012 scenario 9: the body composes title/date + description +
// content, and hides the description slot when empty.

Widget _pump(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('CommunityArticleDetailBody', () {
    testWidgets('renders title, description, and content', (tester) async {
      await tester.pumpWidget(_pump(const CommunityArticleDetailBody(
        title: 'A title',
        publishedAt: '2026-04-08T12:00:00Z',
        description: 'Short lead paragraph.',
        content: 'The full body of the article.',
      )));

      expect(find.text('A title'), findsOneWidget);
      expect(find.text('Short lead paragraph.'), findsOneWidget);
      expect(find.text('The full body of the article.'), findsOneWidget);
      expect(find.byType(CommunityArticleDetailTitleAndDate), findsOneWidget);
    });

    testWidgets(
      'hides the description slot when description is empty',
      (tester) async {
        await tester.pumpWidget(_pump(const CommunityArticleDetailBody(
          title: 'A title',
          publishedAt: '2026-04-08T12:00:00Z',
          description: '',
          content: 'The body.',
        )));

        expect(find.text('A title'), findsOneWidget);
        expect(find.text('The body.'), findsOneWidget);
        // No lead paragraph Text. The only Text widgets should be the
        // title, the date row, and the content — not a description.
        expect(find.byType(CommunityArticleDetailTitleAndDate), findsOneWidget);
      },
    );
  });
}
