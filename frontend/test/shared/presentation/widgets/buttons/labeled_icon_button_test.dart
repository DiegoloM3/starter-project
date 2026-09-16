import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('named constructors carry their word', (tester) async {
    await pumpApp(
      tester,
      Column(
        children: [
          LabeledIconButton.back(onPressed: () {}),
          LabeledIconButton.close(onPressed: () {}),
          LabeledIconButton.cancel(onPressed: () {}),
          LabeledIconButton(icon: Icons.settings, label: 'Settings', onPressed: () {}),
        ],
      ),
    );

    for (final word in ['BACK', 'CLOSE', 'CANCEL', 'SETTINGS']) {
      expect(find.text(word), findsOneWidget);
    }
  });

  testWidgets('is at least 48dp tall', (tester) async {
    await pumpApp(tester, LabeledIconButton.back(onPressed: () {}, backgroundColor: Colors.white));

    expect(tester.getSize(find.byType(LabeledIconButton)).height, greaterThanOrEqualTo(48));
  });
}
