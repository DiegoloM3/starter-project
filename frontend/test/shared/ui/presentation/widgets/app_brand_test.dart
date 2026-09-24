import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/app_brand.dart';

import '../../../../helpers/localized_app.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('the mark says the app name to a screen reader', (tester) async {
    await pump(tester, const AppBrandMark());

    // The mark is a drawing, so without this it is nothing at all to somebody
    // using a screen reader.
    expect(
      find.bySemanticsLabel('Byline'),
      findsOneWidget,
    );
  });

  testWidgets('the mark takes the size it is given', (tester) async {
    await pump(tester, const AppBrandMark(size: 96));

    expect(tester.getSize(find.byType(AppBrandMark)), const Size(96, 96));
  });

  testWidgets('the header names the app and what it is for', (tester) async {
    await pump(
      tester,
      const AppBrandHeader(subtitle: 'Sign in to publish under your own name.'),
    );

    expect(find.text('Byline'), findsOneWidget);
    expect(find.text('Read it. Write it.'), findsOneWidget);
    expect(
      find.text('Sign in to publish under your own name.'),
      findsOneWidget,
    );
  });

  /// The long form (four fields and a helper line) cannot afford the full
  /// header on a short phone, so the tagline goes and the mark shrinks.
  testWidgets('the compact header drops the tagline', (tester) async {
    await pump(
      tester,
      const AppBrandHeader(subtitle: 'Reading is always free.', compact: true),
    );

    expect(find.text('Byline'), findsOneWidget);
    expect(find.text('Read it. Write it.'), findsNothing);
    expect(find.text('Reading is always free.'), findsOneWidget);
  });

  testWidgets('the compact header is shorter than the full one',
      (tester) async {
    await pump(tester, const AppBrandHeader(subtitle: 'A line.'));
    final full = tester.getSize(find.byType(AppBrandHeader)).height;

    await pump(
      tester,
      const AppBrandHeader(subtitle: 'A line.', compact: true),
    );
    final compact = tester.getSize(find.byType(AppBrandHeader)).height;

    expect(compact, lessThan(full));
  });

  testWidgets('the header reads in Spanish on a Spanish device',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: const Scaffold(body: AppBrandHeader(subtitle: 'Hola.')),
      ),
    );

    // The name is a name and does not translate; the tagline does.
    expect(find.text('Byline'), findsOneWidget);
    expect(find.text('Léelo. Escríbelo.'), findsOneWidget);
  });
}
