import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';

void main() {
  testWidgets('renders a standard calendar date instead of a raw timestamp',
      (tester) async {
    const article = ArticleEntity(
      title: 'Daily article',
      description: 'A short description.',
      publishedAt: '2026-09-23T08:00:00Z',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ArticleWidget(article: article)),
      ),
    );

    expect(find.text('2026-09-23'), findsOneWidget);
    expect(find.text('2026-09-23T08:00:00Z'), findsNothing);
  });
}
