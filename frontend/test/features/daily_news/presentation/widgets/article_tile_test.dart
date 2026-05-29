import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../helpers/test_fixtures.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('ArticleWidget', () {
    testWidgets('renders title and author name', (tester) async {
      final article = testArticle(
        title: 'Breaking News',
        authorName: 'Jane Doe',
      );

      await tester.pumpWidget(_wrap(
        ArticleWidget(article: article),
      ));

      expect(find.text('Breaking News'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('renders reading time badge when showReadingTime is true',
        (tester) async {
      final article = testArticle(readingTimeMinutes: 5);

      await tester.pumpWidget(_wrap(
        ArticleWidget(article: article, showReadingTime: true),
      ));

      expect(find.text('5 min read'), findsOneWidget);
    });

    testWidgets('does not render reading time badge when showReadingTime is false',
        (tester) async {
      final article = testArticle(readingTimeMinutes: 5);

      await tester.pumpWidget(_wrap(
        ArticleWidget(article: article, showReadingTime: false),
      ));

      expect(find.text('5 min read'), findsNothing);
    });

    testWidgets('renders status badge when showStatus is true', (tester) async {
      final article = testArticle(status: ArticleStatus.draft);

      await tester.pumpWidget(_wrap(
        ArticleWidget(article: article, showStatus: true),
      ));

      expect(find.text('DRAFT'), findsOneWidget);
    });

    testWidgets('does not render status badge when showStatus is false',
        (tester) async {
      final article = testArticle(status: ArticleStatus.draft);

      await tester.pumpWidget(_wrap(
        ArticleWidget(article: article, showStatus: false),
      ));

      expect(find.text('DRAFT'), findsNothing);
    });

    testWidgets('renders edit and delete buttons when showActions is true',
        (tester) async {
      final article = testArticle();

      await tester.pumpWidget(_wrap(
        ArticleWidget(
          article: article,
          showActions: true,
          onEdit: (_) {},
          onDelete: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('calls onArticlePressed when tapped', (tester) async {
      final article = testArticle(title: 'Tap Me');
      var tapped = false;

      await tester.pumpWidget(_wrap(
        ArticleWidget(
          article: article,
          onArticlePressed: (_) => tapped = true,
        ),
      ));

      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('renders placeholder icon when thumbnail URL is empty',
        (tester) async {
      final article = testArticle(thumbnailUrl: '');

      await tester.pumpWidget(_wrap(
        ArticleWidget(article: article),
      ));

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('renders divider when showDivider is true', (tester) async {
      final article = testArticle();

      await tester.pumpWidget(_wrap(
        ArticleWidget(article: article, showDivider: true),
      ));

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('does not render divider when showDivider is false',
        (tester) async {
      final article = testArticle();

      await tester.pumpWidget(_wrap(
        ArticleWidget(article: article, showDivider: false),
      ));

      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('calls onEdit when edit button is tapped', (tester) async {
      final article = testArticle();
      var editCalled = false;

      await tester.pumpWidget(_wrap(
        ArticleWidget(
          article: article,
          showActions: true,
          onEdit: (_) => editCalled = true,
          onDelete: (_) {},
        ),
      ));

      await tester.tap(find.byIcon(Icons.edit_outlined));
      expect(editCalled, isTrue);
    });

    testWidgets('calls onDelete when delete button is tapped', (tester) async {
      final article = testArticle();
      var deleteCalled = false;

      await tester.pumpWidget(_wrap(
        ArticleWidget(
          article: article,
          showActions: true,
          onEdit: (_) {},
          onDelete: (_) => deleteCalled = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleteCalled, isTrue);
    });
  });
}
