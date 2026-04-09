import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_description.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_detail_body.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_title_and_date.dart';

// Pins spec 011. Composition + edge cases from spec 009 v1.1.x that had
// no widget-level regression coverage.
//
// The sub-widgets (ArticleImage, sanitizer, etc.) are tested on their own.
// These tests verify that ArticleDetailBody wires them together correctly
// and does not re-introduce the force-unwrap crash, the raw JSON body, or
// the red-X image error.

Widget _pump(ArticleEntity article) => MaterialApp(
      home: Scaffold(body: ArticleDetailBody(article: article)),
    );

const _happyArticle = ArticleEntity(
  title: 'A Real Headline',
  description: 'A real description for the article.',
  url: 'https://example.com',
  urlToImage: 'https://example.com/image.png',
  publishedAt: '2026-04-08T12:00:00Z',
  content: 'The actual body of the article as plain text.',
);

const _nullImageArticle = ArticleEntity(
  title: 'Headline Without Image',
  description: 'Description still present.',
  url: 'https://example.com',
  urlToImage: null,
  publishedAt: '2026-04-08T12:00:00Z',
  content: 'Body is fine.',
);

const _nullContentArticle = ArticleEntity(
  title: 'Headline With No Body',
  description: 'Only a description.',
  url: 'https://example.com',
  urlToImage: 'https://example.com/image.png',
  publishedAt: '2026-04-08T12:00:00Z',
  content: null,
);

// The real-world NewsAPI response for the Michael Jackson article that
// triggered the spec 009 v1.1.2 hotfix. If a future refactor regresses
// the sanitizer wiring, this test catches it before it ships.
const _junkContentArticle = ArticleEntity(
  title: 'Michael Jackson Movie Reportedly Suffered \$15 Million Reshoots',
  description: null,
  url: 'https://www.ign.com/articles/michael-jackson-movie',
  urlToImage: null,
  publishedAt: '2026-04-07T17:17:31Z',
  content:
      '{"en":{"access_disabled":"Internet access has been disabled on this device","code":"Code","custom_block_list":"it is on a custom block list"}} [+6792 chars]',
);

void main() {
  group('ArticleDetailBody', () {
    testWidgets('Scenario 1 — happy path composes the three sub-widgets',
        (tester) async {
      await tester.pumpWidget(_pump(_happyArticle));

      expect(find.text('A Real Headline'), findsOneWidget);
      expect(
        find.text(
            'A real description for the article.\n\nThe actual body of the article as plain text.'),
        findsNothing,
        reason:
            'spec 009 v1.1.0 split description and body into separate widgets',
      );
      expect(find.text('A real description for the article.'), findsOneWidget);
      expect(find.text('The actual body of the article as plain text.'),
          findsOneWidget);
      expect(find.byType(ArticleTitleAndDate), findsOneWidget);
      expect(find.byType(ArticleImage), findsOneWidget);
      expect(find.byType(ArticleDescription), findsOneWidget);
    });

    testWidgets(
      'Scenario 2 — null image URL renders the broken_image_outlined placeholder',
      (tester) async {
        await tester.pumpWidget(_pump(_nullImageArticle));

        expect(tester.takeException(), isNull,
            reason:
                'body must not force-unwrap article.urlToImage (spec 009 v1.1.2)');
        expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
        expect(find.text('Headline Without Image'), findsOneWidget);
      },
    );

    testWidgets(
      'Scenario 3 — null content shows the italic fallback line',
      (tester) async {
        await tester.pumpWidget(_pump(_nullContentArticle));

        expect(find.text('Full article available at the source.'),
            findsOneWidget);
        expect(find.text('Only a description.'), findsOneWidget);
      },
    );

    testWidgets(
      'Scenario 4 — JSON scraper junk is hidden and replaced with the fallback',
      (tester) async {
        await tester.pumpWidget(_pump(_junkContentArticle));

        expect(find.text('Full article available at the source.'),
            findsOneWidget);

        // The raw JSON body must not appear anywhere on screen.
        expect(find.textContaining('access_disabled'), findsNothing);
        expect(find.textContaining('custom_block_list'), findsNothing);
        expect(find.textContaining('[+6792 chars]'), findsNothing);
      },
    );
  });
}
