import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/screens/article_published/article_published_screen.dart';

import '../helpers/article_fixtures.dart';
import '../helpers/localized_app.dart';

void main() {
  group('translation files', () {
    /// Message keys only — the `@key` entries next to them are metadata for
    /// the generator and are not translated.
    Set<String> keysOf(String path) {
      final json = jsonDecode(File(path).readAsStringSync()) as Map;

      return json.keys
          .cast<String>()
          .where((key) => !key.startsWith('@'))
          .toSet();
    }

    test('say the same things in both languages', () {
      final english = keysOf('lib/l10n/app_en.arb');
      final spanish = keysOf('lib/l10n/app_es.arb');

      // A key present in one file and missing from the other is how half a
      // screen silently falls back to English. Comparing the sets says which
      // key it was, which a failing screenshot never would.
      expect(
        spanish.difference(english),
        isEmpty,
        reason: 'app_es.arb has keys that app_en.arb does not',
      );
      expect(
        english.difference(spanish),
        isEmpty,
        reason: 'these keys are still untranslated in app_es.arb',
      );
    });

    test('leave nothing empty', () {
      for (final path in ['lib/l10n/app_en.arb', 'lib/l10n/app_es.arb']) {
        final json = jsonDecode(File(path).readAsStringSync()) as Map;

        for (final entry in json.entries) {
          if (entry.key.toString().startsWith('@')) {
            continue;
          }

          expect(
            (entry.value as String).trim(),
            isNotEmpty,
            reason: '${entry.key} is blank in $path',
          );
        }
      }
    });
  });

  group('a screen', () {
    Future<void> pumpIn(WidgetTester tester, Locale locale) {
      return tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: testLocalizationDelegates,
          supportedLocales: testSupportedLocales,
          home: ArticlePublishedScreen(
            article: publishableArticle(status: ArticleStatus.published),
          ),
        ),
      );
    }

    testWidgets('reads in English by default', (tester) async {
      await pumpIn(tester, const Locale('en'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('View article'), findsOneWidget);
      expect(find.text('Back to my articles'), findsOneWidget);
    });

    testWidgets('reads in Spanish on a Spanish device', (tester) async {
      await pumpIn(tester, const Locale('es'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Ver artículo'), findsOneWidget);
      expect(find.text('Volver a mis artículos'), findsOneWidget);
    });

    testWidgets('falls back to English on any other language', (tester) async {
      // Only two languages are translated, and a French phone should get the
      // default rather than a blank screen.
      await pumpIn(tester, const Locale('fr'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('View article'), findsOneWidget);
    });

    testWidgets('never translates the article itself', (tester) async {
      // The app's own words are translated; what a journalist wrote is not.
      final article = publishableArticle(status: ArticleStatus.published);

      await pumpIn(tester, const Locale('es'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(article.title), findsOneWidget);
    });
  });
}
