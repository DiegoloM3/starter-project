import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';

import 'localized_app.dart';

typedef AppAppearance = ({String name, ThemeData theme, Locale locale});

/// Every combination the app can be shown in: light and dark, English and Spanish.
final appearances = ValueVariant<AppAppearance>({
  (name: 'light, English', theme: theme(), locale: const Locale('en')),
  (name: 'dark, English', theme: darkTheme(), locale: const Locale('en')),
  (name: 'light, Spanish', theme: theme(), locale: const Locale('es')),
  (name: 'dark, Spanish', theme: darkTheme(), locale: const Locale('es')),
});

/// Shows [screen] on a phone-sized surface in the current [appearances] value, with the reader's
/// text size set to [textScale].
Future<void> showInEveryAppearance(WidgetTester tester, Widget screen, {double textScale = 1}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final appearance = appearances.currentValue!;
  await tester.pumpWidget(localizedApp(
    theme: appearance.theme,
    locale: appearance.locale,
    home: MediaQuery.withClampedTextScaling(minScaleFactor: textScale, maxScaleFactor: textScale, child: screen),
  ));
  await pumpFrames(tester);
}

/// Not pumpAndSettle: thumbnails never load in tests, so their loading indicator never stops.
Future<void> pumpFrames(WidgetTester tester) async {
  for (var frame = 0; frame < 10; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Buttons big enough to tap on Android and iOS, and labeled for screen readers.
Future<void> expectUsableTapTargets(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

/// Every guideline, text contrast included. The contrast check renders the screen for real, so
/// it is only used on screens without network images: loading them needs plugins tests lack.
Future<void> expectAccessible(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  await expectUsableTapTargets(tester);
}
