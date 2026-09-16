import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/secondary_button.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('is outlined with an optional icon', (tester) async {
    await pumpApp(
      tester,
      SecondaryButton(label: 'Create account', icon: Icons.person_add, onPressed: () {}),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byIcon(Icons.person_add), findsOneWidget);
  });
}
