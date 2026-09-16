import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/destructive_button.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('is outlined by default and filled on request', (tester) async {
    await pumpApp(
      tester,
      Column(
        children: [
          DestructiveButton(label: 'Delete', onPressed: () {}),
          DestructiveButton(label: 'Yes, delete', filled: true, onPressed: () {}),
        ],
      ),
    );

    expect(find.widgetWithText(OutlinedButton, 'Delete'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Yes, delete'), findsOneWidget);
  });
}
