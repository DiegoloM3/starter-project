import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/settings_row.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows value, chevron and reacts to taps', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      SettingsRow(
        label: 'Category',
        value: 'Health',
        icon: Icons.public,
        onTap: () => tapped = true,
      ),
    );

    expect(find.text('Health'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    expect(find.byIcon(Icons.public), findsOneWidget);
    expect(tester.getSize(find.byType(SettingsRow)).height, greaterThanOrEqualTo(60));

    await tester.tap(find.text('Category'));
    expect(tapped, isTrue);
  });

  testWidgets('without onTap it has no chevron', (tester) async {
    await pumpApp(tester, const SettingsRow(label: 'Version', value: '1.0.0'));

    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
  });
}
