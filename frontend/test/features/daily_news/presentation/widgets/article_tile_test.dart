import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_image_placeholder.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/publication_date_text.dart';

void main() {
  Future<void> pumpArticleWidget(WidgetTester tester, ArticleWidget widget) {
    return tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
  }

  group('ArticleWidget', () {
    const article = ArticleEntity(
      title: 'Breaking News!',
      description: 'This is breaking news!',
      publishedAt: '2026-10-15T09:30:00Z',
    );

    testWidgets('shows the title, the description and the date', (tester) async {
      await pumpArticleWidget(tester, const ArticleWidget(article: article));

      expect(find.text('Breaking News!'), findsOneWidget);
      expect(find.text('This is breaking news!'), findsOneWidget);
      expect(find.byType(PublicationDateText), findsOneWidget);
    });

    testWidgets('shows an article without publication date', (tester) async {
      await pumpArticleWidget(tester, const ArticleWidget(article: ArticleEntity(title: 'Breaking News!')));

      expect(tester.takeException(), isNull);
      expect(find.text('Breaking News!'), findsOneWidget);
    });

    testWidgets('shows a placeholder for an article without image', (tester) async {
      await pumpArticleWidget(tester, const ArticleWidget(article: article));

      expect(find.byType(ArticleImagePlaceholder), findsOneWidget);
    });

    testWidgets('reports a tap on the article', (tester) async {
      ArticleEntity? pressedArticle;
      await pumpArticleWidget(
        tester,
        ArticleWidget(article: article, onArticlePressed: (pressed) => pressedArticle = pressed),
      );

      await tester.tap(find.text('Breaking News!'));

      expect(pressedArticle, article);
    });

    testWidgets('lets saved articles be removed', (tester) async {
      ArticleEntity? removedArticle;
      await pumpArticleWidget(
        tester,
        ArticleWidget(article: article, isRemovable: true, onRemove: (removed) => removedArticle = removed),
      );

      await tester.tap(find.byIcon(Icons.remove_circle_outline));

      expect(removedArticle, article);
    });
  });
}
