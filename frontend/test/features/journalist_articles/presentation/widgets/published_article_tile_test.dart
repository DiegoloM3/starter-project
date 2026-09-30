import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/published_article_tile.dart';

import '../../../../helpers/localized_app.dart';

final article = PublishedArticleEntity(
  id: 'article-1',
  title: 'Breaking News',
  content: 'The body.',
  description: 'The body.',
  author: 'Daily News Staff',
  thumbnailUrl: 'https://example.com/1.jpg',
  publishedAt: DateTime.utc(2026, 9, 28, 12),
);

void main() {
  Future<void> showTile(WidgetTester tester) {
    return tester.pumpWidget(localizedApp(
      home: Scaffold(body: PublishedArticleTile(article: article, onPressed: (_) {})),
    ));
  }

  testWidgets('shows the title, the excerpt and who wrote it when', (tester) async {
    await showTile(tester);

    expect(find.text('Breaking News'), findsOneWidget);
    expect(find.text('The body.'), findsOneWidget);
    expect(find.text('Daily News Staff · Sep 28, 2026'), findsOneWidget);
  });

  testWidgets('reports the tapped article', (tester) async {
    PublishedArticleEntity? tapped;
    await tester.pumpWidget(localizedApp(
      home: Scaffold(body: PublishedArticleTile(article: article, onPressed: (pressed) => tapped = pressed)),
    ));

    await tester.tap(find.text('Breaking News'));

    expect(tapped, article);
  });

  testWidgets('shares its hero tag with the article screen image', (tester) async {
    await showTile(tester);

    expect(tester.widget<Hero>(find.byType(Hero)).tag, publishedArticleHeroTag(article));
  });

  group('byline', () {
    testWidgets('adds the reading time only when asked to', (tester) async {
      await tester.pumpWidget(localizedApp(
        home: Column(children: [
          PublishedArticleByline(article: article),
          PublishedArticleByline(article: article, showsReadingTime: true),
        ]),
      ));

      expect(find.text('Daily News Staff · Sep 28, 2026'), findsOneWidget);
      expect(find.text('Daily News Staff · Sep 28, 2026 · 1 min read'), findsOneWidget);
    });

    testWidgets('writes the date and reading time in Spanish', (tester) async {
      await tester.pumpWidget(localizedApp(
        locale: const Locale('es'),
        home: PublishedArticleByline(article: article, showsReadingTime: true),
      ));

      expect(find.text('Daily News Staff · 28 sept 2026 · 1 min de lectura'), findsOneWidget);
    });
  });
}
