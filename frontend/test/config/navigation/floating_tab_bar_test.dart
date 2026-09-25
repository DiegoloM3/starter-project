import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/navigation/floating_tab_bar.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

Widget _app({int selectedIndex = 0, Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      bottomNavigationBar: FloatingTabBar(
        selectedIndex: selectedIndex,
        onTabSelected: (_) {},
        onCreatePressed: () {},
      ),
    ),
  );
}

void main() {
  testWidgets('stays a slim bar at the bottom, not the whole screen',
      (tester) async {
    await tester.pumpWidget(_app());

    final size = tester.getSize(find.byType(FloatingTabBar));
    expect(size.height, lessThan(100));
  });

  testWidgets('fits a 320dp-wide phone without overflowing', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(selectedIndex: 3));

    expect(tester.takeException(), isNull);
  });

  testWidgets('names the "+" in the chosen language', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('es')));

    expect(find.byTooltip('Nuevo artículo'), findsOneWidget);
  });
}
