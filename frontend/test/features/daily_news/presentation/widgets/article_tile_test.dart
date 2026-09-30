import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/localized_app.dart';

const article = ArticleEntity(
  title: 'Nvidia announces a stock buyback',
  description: 'The valuation is too appetizing',
  publishedAt: '2026-09-28T12:13:42Z',
);

void main() {
  testWidgets('shows a placeholder for an article without an image', (tester) async {
    await tester.pumpWidget(localizedApp(home: const Scaffold(body: ArticleWidget(article: article))));

    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    expect(find.text('Nvidia announces a stock buyback'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reports the tapped article', (tester) async {
    ArticleEntity? tapped;
    await tester.pumpWidget(localizedApp(
      home: Scaffold(body: ArticleWidget(article: article, onArticlePressed: (pressed) => tapped = pressed)),
    ));

    await tester.tap(find.text('Nvidia announces a stock buyback'));

    expect(tapped, article);
  });

  testWidgets('offers to remove a saved article', (tester) async {
    ArticleEntity? removed;
    await tester.pumpWidget(localizedApp(
      home: Scaffold(
        body: ArticleWidget(article: article, isRemovable: true, onRemove: (pressed) => removed = pressed),
      ),
    ));

    await tester.tap(find.byIcon(Icons.remove_circle_outline));

    expect(removed, article);
  });

  testWidgets('fits with the text at 200 %', (tester) async {
    const longArticle = ArticleEntity(
      title: 'Nvidia announces a jaw-dropping stock buyback, the largest in its history',
      description: 'The valuation on Nvidia is too appetizing for its chief executive',
      urlToImage: 'https://example.com/nvidia.jpg',
      publishedAt: '2026-09-28T12:13:42Z',
    );
    await showInEveryAppearance(tester, const Scaffold(body: ArticleWidget(article: longArticle)), textScale: 2);

    expect(tester.takeException(), isNull);
  }, variant: appearances);
}
