import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows icons and fires its callback', (tester) async {
    var pressed = false;
    await pumpApp(
      tester,
      PrimaryButton(
        label: 'Start reading',
        icon: Icons.play_arrow_rounded,
        trailingIcon: Icons.arrow_forward_rounded,
        onPressed: () => pressed = true,
      ),
    );

    await tester.tap(find.text('Start reading'));
    expect(pressed, isTrue);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
  });

  testWidgets('while loading it shows a spinner and cannot be pressed', (tester) async {
    var pressed = false;
    await pumpApp(
      tester,
      PrimaryButton(label: 'Publishing…', isLoading: true, onPressed: () => pressed = true),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Publishing…'), warnIfMissed: false);
    expect(pressed, isFalse);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).enabled, isFalse);
  });
}
