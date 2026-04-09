import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/base_network_image.dart';

void main() {
  group('ArticleWidget Tests', () {
    const testArticle = ArticleEntity(
      id: '1',
      title: 'Test Title',
      description: 'Test Description',
      url: 'https://example.com/image.jpg',
      publishedAt: '2023-10-10T00:00:00Z',
    );

    Widget createWidgetUnderTest({
      required ArticleEntity article,
      bool isRemovable = false,
      void Function(ArticleEntity)? onRemove,
      void Function(ArticleEntity)? onArticlePressed,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ArticleWidget(
            article: article,
            isRemovable: isRemovable,
            onRemove: onRemove ?? (_) {},
            onArticlePressed: onArticlePressed ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('Should render article details correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(article: testArticle));

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);

      expect(find.text('10/10/2023'), findsOneWidget);

      final imageFinder = find.byType(BaseNetworkImage);
      expect(imageFinder, findsOneWidget);
      final imageWidget = tester.widget<BaseNetworkImage>(imageFinder);
      expect(imageWidget.imageUrl, testArticle.url);

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('Should handle null title and description by showing empty strings', (WidgetTester tester) async {
      const nullArticle = ArticleEntity(
        id: '2',
        title: null,
        description: null,
        url: 'https://example.com/image.jpg',
        publishedAt: '2023-10-10T00:00:00Z',
      );

      await tester.pumpWidget(createWidgetUnderTest(article: nullArticle));

      expect(find.byType(ArticleWidget), findsOneWidget);
      
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      
      expect(textWidgets.length, greaterThanOrEqualTo(2));
      expect(textWidgets.any((t) => t.data == ''), isTrue);
    });

    testWidgets('Should call onArticlePressed when the tile is tapped', (WidgetTester tester) async {
      bool pressed = false;
      ArticleEntity? pressedArticle;

      await tester.pumpWidget(
        createWidgetUnderTest(
          article: testArticle,
          onArticlePressed: (article) {
            pressed = true;
            pressedArticle = article;
          },
        ),
      );

      await tester.tap(find.byType(ArticleWidget));
      await tester.pump();

      expect(pressed, isTrue);
      expect(pressedArticle, testArticle);
    });

    testWidgets('Should show remove button and call onRemove when isRemovable is true', (WidgetTester tester) async {
      bool removed = false;
      ArticleEntity? removedArticle;

      await tester.pumpWidget(
        createWidgetUnderTest(
          article: testArticle,
          isRemovable: true,
          onRemove: (article) {
            removed = true;
            removedArticle = article;
          },
        ),
      );

      final closeIconFinder = find.byIcon(Icons.close);
      expect(closeIconFinder, findsOneWidget);

      await tester.tap(closeIconFinder);
      await tester.pump();

      expect(removed, isTrue);
      expect(removedArticle, testArticle);
    });

    testWidgets('Should NOT show remove button when isRemovable is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          article: testArticle,
          isRemovable: false,
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('Should verify BaseNetworkImage layout properties', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(article: testArticle));

      final imageFinder = find.byType(BaseNetworkImage);
      final imageWidget = tester.widget<BaseNetworkImage>(imageFinder);
      
      expect(imageWidget.width, 800 / 3);
      expect(imageWidget.height, double.maxFinite);
    });
  });
}
