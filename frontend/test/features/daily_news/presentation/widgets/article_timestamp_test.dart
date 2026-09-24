import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_timestamp.dart';

import '../../../../helpers/localized_app.dart';

void main() {
  Future<void> pumpTimestamp(WidgetTester tester, String? rawDate) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: Scaffold(body: ArticleTimestamp(rawDate: rawDate)),
      ),
    );
  }

  // How the wording is chosen is RelativeTime's business and is covered in
  // its own test. What matters here is that the widget shows it at all, and
  // what it does when there is nothing to show.

  testWidgets('shows when the article was published', (tester) async {
    final anHourAgo = DateTime.now().subtract(const Duration(hours: 1));

    await pumpTimestamp(tester, anHourAgo.toIso8601String());

    expect(find.text('1h ago'), findsOneWidget);
  });

  testWidgets('takes up no room at all for a date it cannot read', (
    tester,
  ) async {
    // The News API hands publishedAt over as a plain string, so a value that
    // is not a date is a real case. An empty Text would still occupy a line
    // and push the layout around, so the widget collapses instead.
    await pumpTimestamp(tester, 'not a date');

    expect(find.byType(Text), findsNothing);
    expect(tester.getSize(find.byType(ArticleTimestamp)), Size.zero);
  });

  testWidgets('shows nothing when there is no date', (tester) async {
    await pumpTimestamp(tester, null);

    expect(find.byType(Text), findsNothing);
  });
}
