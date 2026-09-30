import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/article_detail/article_detail.dart';

import '../../../../../helpers/localized_app.dart';

void main() {
  testWidgets('shows the article without an image when NewsAPI has none', (tester) async {
    const article = ArticleEntity(
      title: 'Nvidia announces a stock buyback',
      description: 'The valuation is too appetizing.',
      content: 'The rest of the story.',
      publishedAt: '2026-09-28T12:13:42Z',
    );

    await tester.pumpWidget(localizedApp(home: const ArticleDetailsView(article: article)));

    expect(find.text('Nvidia announces a stock buyback'), findsOneWidget);
    expect(find.textContaining('The rest of the story.'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
