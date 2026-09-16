import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/settings_row.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/settings_section.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('upper-cases its title and divides its rows', (tester) async {
    await pumpApp(
      tester,
      const SettingsSection(
        title: 'Feed',
        children: [SettingsRow(label: 'One'), SettingsRow(label: 'Two')],
      ),
    );

    expect(find.text('FEED'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });
}
