import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/screens/article_published/article_published_screen.dart';

import '../../../../../helpers/article_fixtures.dart';
import '../../../../../helpers/localized_app.dart';

void main() {
  final article = publishableArticle(
    id: 'a-1',
    status: ArticleStatus.published,
  ).copyWith(title: 'The Future of Urban Gardens');

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: ArticlePublishedScreen(article: article),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('says plainly what just happened', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Your article is live'), findsOneWidget);
    expect(
      find.text('Anyone can now read it in the Community feed.'),
      findsOneWidget,
    );
  });

  testWidgets('shows which article was published', (tester) async {
    await pumpScreen(tester);

    // Confirming *that* something was published is weaker than confirming
    // which thing was.
    expect(find.text('The Future of Urban Gardens'), findsOneWidget);
  });

  testWidgets('offers both ways on from here', (tester) async {
    await pumpScreen(tester);

    expect(find.widgetWithText(FilledButton, 'View article'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, 'Back to my articles'),
      findsOneWidget,
    );
  });

  testWidgets('has no way back into the editor it came from', (tester) async {
    await pumpScreen(tester);

    // The article is already public; there is nothing to go back and finish.
    expect(find.byType(BackButton), findsNothing);
  });
}
