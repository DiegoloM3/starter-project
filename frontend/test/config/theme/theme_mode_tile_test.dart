import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/theme_cubit.dart';
import 'package:news_app_clean_architecture/config/theme/theme_mode_tile.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

void main() {
  test('starts in light mode', () {
    final cubit = ThemeCubit();
    addTearDown(cubit.close);

    expect(cubit.state, ThemeMode.light);
  });

  testWidgets('tapping a segment switches the app to that mode',
      (tester) async {
    final cubit = ThemeCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: BlocProvider.value(
        value: cubit,
        child: const Scaffold(body: ThemeModeTile()),
      ),
    ));

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pump();

    expect(cubit.state, ThemeMode.dark);
  });
}
