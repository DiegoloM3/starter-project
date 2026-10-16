import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_byline.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/journalist_badge.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/publication_date_text.dart';

void main() {
  Future<void> pumpByline(WidgetTester tester, ArticleEntity article) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ArticleByline(article: article, dateIcon: Icons.timeline_outlined)),
    ));
  }

  group('ArticleByline', () {
    testWidgets('marks the articles written by journalists', (tester) async {
      await pumpByline(tester, PublishedArticleEntity(
        title: 'Breaking News!',
        content: 'Content',
        thumbnailUrl: 'https://example.com/thumbnail.jpg',
        publishedAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ));

      expect(find.byType(JournalistBadge), findsOneWidget);
      expect(find.text('Journalist'), findsOneWidget);
      expect(find.text('3 minutes ago'), findsOneWidget);
    });

    testWidgets('does not mark the articles of the news API', (tester) async {
      await pumpByline(tester, const ArticleEntity(publishedAt: '2026-10-01T12:00:00Z'));

      expect(find.byType(JournalistBadge), findsNothing);
      expect(find.byType(PublicationDateText), findsOneWidget);
    });

    testWidgets('hides the date of an article without publication date', (tester) async {
      await pumpByline(tester, const ArticleEntity(title: 'Breaking News!'));

      expect(tester.takeException(), isNull);
      expect(find.byType(PublicationDateText), findsNothing);
      expect(find.byIcon(Icons.timeline_outlined), findsNothing);
    });
  });
}
