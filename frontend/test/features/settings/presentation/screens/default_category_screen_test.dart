import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/default_category_screen.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late SettingsHarness settings;

  void createSettings() {
    settings = SettingsHarness();
    addTearDown(settings.dispose);
  }

  testWidgets('lists every category, marks the current one and saves the tap', (tester) async {
    createSettings();
    await pumpApp(
      tester,
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const DefaultCategoryScreen()),
          ),
          child: const Text('open'),
        ),
      ),
      providers: [BlocProvider.value(value: settings.cubit)],
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('DEFAULT CATEGORY'), findsOneWidget);
    for (final category in NewsCategory.values) {
      expect(find.text(category.label), findsOneWidget);
    }
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('Health'));
    await tester.pumpAndSettle();

    expect(settings.cubit.state.settings.defaultCategory, NewsCategory.health);
    expect(find.byType(DefaultCategoryScreen), findsNothing);
  });
}
